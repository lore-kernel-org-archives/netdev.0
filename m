From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 19:48:43 -0800 (PST)
Message-ID: <20071231.194843.136619677.davem@davemloft.net>
References: <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
	<20071231193848.GQ27894@ZenIV.linux.org.uk>
	<alpine.LSU.0.999.0801010418260.2337@be1.lrz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, jengelh@computergmbh.de, devzero@web.de,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: 7eggert@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbYAADso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 22:48:44 -0500
In-Reply-To: <alpine.LSU.0.999.0801010418260.2337@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bodo Eggert <7eggert@gmx.de>
Date: Tue, 1 Jan 2008 04:45:21 +0100 (CET)

> The big question is: Is there any non-embedded system where you have
> to aim for a small kernel image?

One some platforms, due to bootloader restrictions or whatever,
there are hard limits on how large the main kernel image can be.

On sparc64 for example the limit is around 6.5MB

But this "big question" isn't the important issue, in fact it's
tangental and has no bearing on the final decision we make
here.

Rather, choice is, and taking choice away is bad.  I may have a reason
to make AF_UNIX modular, I might not, but either way taking that
option away from me is not the right thing to do.
