From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: jumbo frames and memory fragmentation
Date: Fri, 30 Jun 2006 17:04:42 -0700
Message-ID: <4807377b0606301704t251aaf58r132d8c1ff54dcc68@mail.gmail.com>
References: <E1FwIcw-00068x-00@gondolin.me.apana.org.au>
	 <44A56520.5010703@nortel.com> <20060630184820.GA9558@2ka.mipt.ru>
	 <44A5B546.3010606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:13853 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S964841AbWGAAEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 20:04:43 -0400
Received: by ug-out-1314.google.com with SMTP id c2so958210ugf
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 17:04:42 -0700 (PDT)
To: "Chris Friesen" <cfriesen@nortel.com>
In-Reply-To: <44A5B546.3010606@nortel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/30/06, Chris Friesen <cfriesen@nortel.com> wrote:
> Evgeniy Polyakov wrote:
>
> > It definitely will.
> > Packet split in hardware means separating data and headers into
> > different pages in different reads, while software page split means that
> > skb has a list of fragments where part of the packet will be DMAed, so
> > jumbo frame will be converted into several pages.
>
> Maybe I'm looking at the wrong code then.  Can you point me to where
> this "software page split" is handled?

You're right, it isn't supported for your hardware.  to solve the
problem (I got this from mailing lists) you probably need to adjust
the /proc/sys/vm/min_free_kbytes

let us know if this helps for you.
