From: "Denys" <denys@visp.net.lb>
Subject: Re: HFSC dangerous behaviour (not a bug)
Date: Mon, 29 Oct 2007 13:45:26 +0200
Message-ID: <20071029114405.M87941@visp.net.lb>
References: <20071028235224.M3269@visp.net.lb> <4725BC23.7000907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:58246 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbXJ2Lpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 07:45:49 -0400
In-Reply-To: <4725BC23.7000907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After thinking about that, i can say only thanks.
I like your idea, and it is better to avoid mistakes and missed traffic, then 
have a lot of complaints from users "why my shaper not working well". And 
seems i will try to switch to HFSC.

Thanks for explanation.

On Mon, 29 Oct 2007 11:55:31 +0100, Patrick McHardy wrote
> Denys wrote:
> > Hi All
> > 
> > During testing i found very strange thing. 
> > After applying even example shaper:
> > http://linux-ip.net/tc/hfsc.en/
> > -------------
> > [...]
> > ---------------
> > I had all traffic on eth0 stopped. Tried on br0 - same result. Even ARP 
> > becoming non-functional.
> > 
> > After specifying correct default class everything worked fine.
> > 
> > In HTB if you dont specify default class, traffic just pass without 
> > "shaping".
> 
> HFSC drops unclassified packets. If you don't classify ARP properly,
> things will break,
> 
> > Is it possible to keep same behaviour on both disciplines?
> > Probably just dropping all traffic not good idea, cause if user working 
on 
> > remote box by forgetting specifying default class or by mistake using 
> > incorrect class number he will loose access to the box, if same interface 
is 
> > used for tests on shaping and access.
> > In same time it is good, and can show accurate results on shaping, 
without 
> > bypassing some "forgotten" traffic.
> > But at least it must be same, IMHO, on HTB and HFSC.
> 
> This came up a couple of times already. I don't like HTB's behaviour
> since you don't notice when your classifiers are incomplete. So I'm
> against changing HFSC to behave similar. HTB OTOH can't be changed
> since users probably rely on that, not classifying ARP is a common
> mistake.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

