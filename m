From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 13:09:10 +0200
Message-ID: <20080308110611.M62976@visp.net.lb>
References: <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45383 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbYCHLJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 06:09:20 -0500
In-Reply-To: <20080308105250.GB3301@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems "try 2" helped. lockdep is not triggered anymore. I test on 3 different 
servers for now.
I will test more deeply and on more servers.


On Sat, 8 Mar 2008 11:52:50 +0100, Jarek Poplawski wrote
> On Sat, Mar 08, 2008 at 11:43:22AM +0100, Jarek Poplawski wrote:
> ....
> > ...Hmm... the same day I sent to you "take 2" of my patch which was more
> > complete (lockdep_set_class for ingress_lock added). Could you try this?
> > It still could be not enough, and something similar is needed for
> > tcfc_lock in act_mirred, but I'd like to see a report after this patch
> > first.
> 
> ....Hmm#2... or maybe it doesn't matter? I'll try to send you today
> this additional act_mirred patch.
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

