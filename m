From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 15:03:20 +0100 (CET)
Message-ID: <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
 <20071231.042055.145660385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: 7eggert@gmx.de, jengelh@computergmbh.de, devzero@web.de,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759305AbXLaODo@vger.kernel.org>
In-Reply-To: <20071231.042055.145660385.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Dec 2007, David Miller wrote:
> From: Bodo Eggert <7eggert@gmx.de>

> > As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> > on normal systems. This is especially true since udev needs these sockets
> > and fails to run if UNIX=m.
> > 
> > Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
> 
> People who use udev can make sure they have it built into their kernel
> if they have such a dependency.
> 
> Not everyone uses udev, and therefore needs AF_UNIX non-modular.

That's why I kept this option for embedded folks.

Is there any benefit for non-embedded systems from having UNIX=m?
-- 
Top 100 things you don't want the sysadmin to say:
89. I got a better job at Lockheed...
