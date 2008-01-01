From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Tue, 1 Jan 2008 04:45:21 +0100 (CET)
Message-ID: <alpine.LSU.0.999.0801010418260.2337@be1.lrz>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
 <20071231.042055.145660385.davem@davemloft.net> <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
 <20071231193848.GQ27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Bodo Eggert <7eggert@gmx.de>, David Miller <davem@davemloft.net>,
	jengelh@computergmbh.de, devzero@web.de,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753878AbYAADpk@vger.kernel.org>
In-Reply-To: <20071231193848.GQ27894@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Dec 2007, Al Viro wrote:
> On Mon, Dec 31, 2007 at 03:03:20PM +0100, Bodo Eggert wrote:
> > On Mon, 31 Dec 2007, David Miller wrote:
> > > From: Bodo Eggert <7eggert@gmx.de>

> > > > As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> > > > on normal systems. This is especially true since udev needs these sockets
> > > > and fails to run if UNIX=m.
> > > > 
> > > > Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
> > > 
> > > People who use udev can make sure they have it built into their kernel
> > > if they have such a dependency.
> > > 
> > > Not everyone uses udev, and therefore needs AF_UNIX non-modular.
> > 
> > That's why I kept this option for embedded folks.
> > 
> > Is there any benefit for non-embedded systems from having UNIX=m?
> 
> udev-free != embedded.

But UNIX=m == waste RAM and have an effectively b0rken system until the 
module is loaded. It would be silly to do this unless you have a very small 
space for the kernel image and some free space for storing the needed 
modules. The big question is: Is there any non-embedded system where you 
have to aim for a small kernel image?

-- 
Fun things to slip into your budget
Half a million dollars for consultants to design a web site that was being
done by an intern in his spare time.
