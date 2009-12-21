From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Mon, 21 Dec 2009 11:32:39 -0800 (PST)
Message-ID: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
References: <20091219111206.GA5307@wrars-comp.wrarsdomain> <20091220200343.GA5427@wrars-comp.wrarsdomain> <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de> <20091221181839.GA5232@wrars-comp.wrarsdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org
To: Andrey Rahmatullin <wrar@altlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59373 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbZLUTcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 14:32:42 -0500
In-Reply-To: <20091221181839.GA5232@wrars-comp.wrarsdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Dec 2009 at 23:18, Andrey Rahmatullin wrote:
> I've installed 2.6.27, the earliest kernel supported by udev 149. I
[...]
> one of downloads, waited for some time, nothing happened. I resumed the
> second download, the kernel crashed into an endless stream of backtraces
> (did 2.6.27 support pause_on_oops?), containing "whatever from the idle
> thread", or smth like that, which was also in other crash logs.

So, 2.6.27 crashed as well. Was the backtrace similar to those on 2.6.30? 
I know it's a long shot, but since you seem to be able to reproduce this 
pretty reliably, can you try 2.6.23? Or at least something before 
bea3348eef27e6044b6161fd04c3152215f96411 [0]?

Christian.

[0] I'm *really* guessing here, if some netdev guru has some better
    understanding of the backtraces Andrey sent, please step forward.
-- 
BOFH excuse #433:

error: one bad user found in front of screen
