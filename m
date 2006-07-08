From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: jumbo frames and memory fragmentation
Date: Sun, 9 Jul 2006 02:25:09 +0400
Message-ID: <20060708222509.GF26000@2ka.mipt.ru>
References: <E1FwIcw-00068x-00@gondolin.me.apana.org.au> <44A56520.5010703@nortel.com> <20060630184820.GA9558@2ka.mipt.ru> <44A5B546.3010606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:31699 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751314AbWGHWZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 18:25:40 -0400
To: Chris Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <44A5B546.3010606@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 05:35:34PM -0600, Chris Friesen (cfriesen@nortel.com) wrote:
> Evgeniy Polyakov wrote:
> 
> >It definitely will.
> >Packet split in hardware means separating data and headers into
> >different pages in different reads, while software page split means that 
> >skb has a list of fragments where part of the packet will be DMAed, so
> >jumbo frame will be converted into several pages.
> 
> Maybe I'm looking at the wrong code then.  Can you point me to where 
> this "software page split" is handled?

Yes, you are correct, e1000 only supports receiving page split for 82571 and
greater adapters.

> Chris

-- 
	Evgeniy Polyakov
