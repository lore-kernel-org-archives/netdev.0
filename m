From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 21:35:31 +0200
Message-ID: <20090519193531.GD2981@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <20090518175352.GB2755@ami.dom.local> <298f5c050905181123o55c35e74n24cd4ee2c07d8fca@mail.gmail.com> <20090518183221.GC2755@ami.dom.local> <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com> <20090518190541.GA3047@ami.dom.local> <Pine.LNX.4.64.0905191517350.4730@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Eric Dumazet <dada1@cosmosbay.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:46996 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbZESTgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:36:17 -0400
Received: by bwz22 with SMTP id 22so4671bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 12:36:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905191517350.4730@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 03:18:47PM +0200, Jesper Dangaard Brouer wrote:
>
> On Mon, 18 May 2009, Jarek Poplawski wrote:
>
>> Since you're so kind... :-) There is a line in net/sched/sch_htb.c:
>>
>> #define HTB_HYSTERESIS 1        /* whether to use mode hysteresis for speedup */
>>
>> Could you change 1 to 0, and repeat these tests above after recompiling?
>
> Notice its runtime adjustable via:
>  /sys/module/sch_htb/parameters/htb_hysteresis
>
> Since kernel version v2.6.26.

Yes, this should convince Antonio to try something newer.
(Alas it didn't seem to make much difference to his case ;-)

Cheers,
Jarek P.
