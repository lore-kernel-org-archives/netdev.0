From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: testing crazy stuff with iproute2
Date: Fri, 28 Dec 2007 11:18:27 +0100
Message-ID: <20071228101827.GE1618@ff.dom.local>
References: <20071226045037.M75814@visp.net.lb> <4774146D.1030502@gmail.com> <20071227212405.M87764@visp.net.lb> <20071227225455.GA6672@ami.dom.local> <20071227233749.M11574@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:23300 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbXL1KMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 05:12:48 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1786974ugc.16
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2007 02:12:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071227233749.M11574@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2007 at 01:44:17AM +0200, Denys Fedoryshchenko wrote:
...
> For bandwidth sharing it is perfect, but i want just to make things, which i 
> did with TBF - some time bursty speed, and then slow down to lower speed if 
> customer is using too much. In theory it has to work like this, but in 
> practice i am hitting wall. I tried it about 1 year ago, it was same thing, 
> just with another conditions. Seems cburst/burst a bit different thing, just 
> to make load on CPU by HTB less , at high speeds.

IMHO it's quite possible you're trying to use HTB to things it is
not intended to do. cburst/burst have to limit burstiness and not
change rates depending on load. But, maybe they could do the other
things too whith some tricks, I don't know. I think CBQ or maybe
HFSC could be better for you. But, if TBF works for you, and you
don't need sharing (lending) I don't understand why to 'fight'
with HTB at all. You could maybe use it only to get class hierarchy
with some high, not limiting rates, or even try e.g. prio + TBF
combination.

Regards,
Jarek P.
