From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 04:20:55 -0800 (PST)
Message-ID: <20071231.042055.145660385.davem@davemloft.net>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@computergmbh.de, devzero@web.de,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: 7eggert@gmx.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759382AbXLaMVK@vger.kernel.org>
In-Reply-To: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bodo Eggert <7eggert@gmx.de>
Date: Mon, 31 Dec 2007 13:09:43 +0100 (CET)

> As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> on normal systems. This is especially true since udev needs these sockets
> and fails to run if UNIX=m.
> 
> Signed-Off-By: Bodo Eggert <7eggert@gmx.de>

People who use udev can make sure they have it built into their kernel
if they have such a dependency.

Not everyone uses udev, and therefore needs AF_UNIX non-modular.

I keep seeing this crap patch get submitted and I'm going to keep
dropping it because it's bogus.

It seems to stem from some filesystem interface or whatever that the
VFS folks don't want to export or one they want to now stop exporting.

But that is a really cruddy reason to want to force AF_UNIX to not
be allowed to be modular, and the udev thing just makes it more of a
joke rather than a good technical reason.
