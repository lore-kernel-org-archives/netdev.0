From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Wed, 19 Mar 2008 02:46:08 +0200
Message-ID: <20080319004547.M71837@visp.net.lb>
References: <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local> <20080308110611.M62976@visp.net.lb> <20080308120244.GA3378@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:42062 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758405AbYCSTot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:44:49 -0400
In-Reply-To: <20080308120244.GA3378@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No more warnings.
Probably it must be applied to 2.6.25 before it is released?

On Sat, 8 Mar 2008 13:02:44 +0100, Jarek Poplawski wrote
> On Sat, Mar 08, 2008 at 01:09:10PM +0200, Denys Fedoryshchenko wrote:
> > Seems "try 2" helped. lockdep is not triggered anymore. I test on 3 
different 
> > servers for now.
> > I will test more deeply and on more servers.
> 
> Fine! So, let's wait yet... (No need to hurry.)
> 
> BTW, I thought about those earlier probably stack overflow problems,
> and I wonder if using action ipt couldn't be blamed here. Sometimes
> it seems to be unnecessary, so maybe you could try if re-doing some
> filter rules can help.
> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

