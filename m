From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] napi: limit GRO latency
Date: Mon, 08 Oct 2012 21:46:32 +0200
Message-ID: <1349725592.21172.3685.camel@edumazet-glaptop>
References: <1349718955.21172.3534.camel@edumazet-glaptop>
	 <1349719006.21172.3537.camel@edumazet-glaptop>
	 <20121008115835.3a3bfed6@nehalam.linuxnetplumber.net>
	 <20121008.151035.1665672334154033755.davem@davemloft.net>
	 <20121008121248.783e6dc4@nehalam.linuxnetplumber.net>
	 <1349724612.21172.3643.camel@edumazet-glaptop>
	 <20121008124026.4057aba8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38788 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab2JHTqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:46:38 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2249644bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 12:46:36 -0700 (PDT)
In-Reply-To: <20121008124026.4057aba8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 12:40 -0700, Stephen Hemminger wrote:
> On Mon, 08 Oct 2012 21:30:12 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > System is under stress, you dont want to increase load at this point,
> > but increase bandwidth.
> > 
> > Really try this on a 40Gbe link and see how bad it is.
> 
> Not everybody has 40Gbe hardware just lying around available for testing :-)

;)

In fact, the current strategy to flush napi_gro when napi completes
might be not good for moderate traffic (thats 99% of the linux machines
I believe). We could have a deferred flush instead...

I dont know what strategy is used by hardware. But surely hardware uses
timers.
