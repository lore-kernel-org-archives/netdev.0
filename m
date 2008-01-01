From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Tue, 1 Jan 2008 05:48:06 +0100 (CET)
Message-ID: <alpine.LSU.0.999.0801010459500.12978@be1.lrz>
References: <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
 <20071231193848.GQ27894@ZenIV.linux.org.uk> <alpine.LSU.0.999.0801010418260.2337@be1.lrz>
 <20071231.194843.136619677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: 7eggert@gmx.de, viro@ZenIV.linux.org.uk, jengelh@computergmbh.de,
	devzero@web.de, linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61428 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbYAAEse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 23:48:34 -0500
In-Reply-To: <20071231.194843.136619677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Dec 2007, David Miller wrote:
> From: Bodo Eggert <7eggert@gmx.de>

> > The big question is: Is there any non-embedded system where you have
> > to aim for a small kernel image?
> 
> One some platforms, due to bootloader restrictions or whatever,
> there are hard limits on how large the main kernel image can be.
> 
> On sparc64 for example the limit is around 6.5MB

That would be about the size of a complete rescue system. I don't think we 
need to worry about unix sockets there, do we?

> But this "big question" isn't the important issue, in fact it's
> tangental and has no bearing on the final decision we make
> here.
> 
> Rather, choice is, and taking choice away is bad.  I may have a reason
> to make AF_UNIX modular, I might not, but either way taking that
> option away from me is not the right thing to do.

_You_'ll still have the option, because you have selected EMBEDDED=y 
(otherwise, you'd miss all other valuable options to cripple your kernel), 
while the folks that just care for a working systems will have what they'd 
select anyway without being bothered with useless questions.
-- 
Top 100 things you don't want the sysadmin to say:
5. Just add yourself to the password file and make a directory...
