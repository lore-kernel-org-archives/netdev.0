From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: testing crazy stuff with iproute2
Date: Fri, 28 Dec 2007 15:20:13 +0200
Message-ID: <20071228131932.M39091@visp.net.lb>
References: <20071226045037.M75814@visp.net.lb> <4774146D.1030502@gmail.com> <20071227212405.M87764@visp.net.lb> <20071227225455.GA6672@ami.dom.local> <20071227233749.M11574@visp.net.lb> <20071228101827.GE1618@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:36642 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbXL1OR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 09:17:26 -0500
In-Reply-To: <20071228101827.GE1618@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prio is limited. I can have on PPPoE up to 500-600 customers, and i need to 
create for each in ifb device class/qdisc. So prio will not fit.

On Fri, 28 Dec 2007 11:18:27 +0100, Jarek Poplawski wrote
> On Fri, Dec 28, 2007 at 01:44:17AM +0200, Denys Fedoryshchenko wrote:
> ....
> > For bandwidth sharing it is perfect, but i want just to make things, 
which i 
> > did with TBF - some time bursty speed, and then slow down to lower speed 
if 
> > customer is using too much. In theory it has to work like this, but in 
> > practice i am hitting wall. I tried it about 1 year ago, it was same 
thing, 
> > just with another conditions. Seems cburst/burst a bit different thing, 
just 
> > to make load on CPU by HTB less , at high speeds.
> 
> IMHO it's quite possible you're trying to use HTB to things it is
> not intended to do. cburst/burst have to limit burstiness and not
> change rates depending on load. But, maybe they could do the other
> things too whith some tricks, I don't know. I think CBQ or maybe
> HFSC could be better for you. But, if TBF works for you, and you
> don't need sharing (lending) I don't understand why to 'fight'
> with HTB at all. You could maybe use it only to get class hierarchy
> with some high, not limiting rates, or even try e.g. prio + TBF
> combination.
> 
> Regards,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

