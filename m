From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 02 Jun 2009 23:50:42 +0200
Message-ID: <4A259EB2.5010500@gmail.com>
References: <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com> <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:54652 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbZFBVu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:50:57 -0400
Received: by fg-out-1718.google.com with SMTP id d23so970875fga.17
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 14:50:58 -0700 (PDT)
In-Reply-To: <20090602213723.GB2850@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/02/2009 11:37 PM:
...

> I described the reasoning here:
> http://permalink.gmane.org/gmane.linux.network/128189

The link is stuck now, so here is a quote:

Jarek Poplawski wrote, On 05/17/2009 10:15 PM:

> Here is some additional explanation. It looks like these rates above
> 500Mbit hit the design limits of packet scheduling. Currently used
> internal resolution PSCHED_TICKS_PER_SEC is 1,000,000. 550Mbit rate
> with 800byte packets means 550M/8/800 = 85938 packets/s, so on average
> 1000000/85938 = 11.6 ticks per packet. Accounting only 11 ticks means
> we leave 0.6*85938 = 51563 ticks per second, letting for additional
> sending of 51563/11 = 4687 packets/s or 4687*800*8 = 30Mbit. Of course
> it could be worse (0.9 tick/packet lost) depending on packet sizes vs.
> rates, and the effect rises for higher rates.


Jarek P.
