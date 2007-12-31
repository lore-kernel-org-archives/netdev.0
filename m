From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 19:38:48 +0000
Message-ID: <20071231193848.GQ27894@ZenIV.linux.org.uk>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz> <20071231.042055.145660385.davem@davemloft.net> <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jengelh@computergmbh.de,
	devzero@web.de, linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51263 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbXLaTiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 14:38:52 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.0.999.0712311426520.3761@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 03:03:20PM +0100, Bodo Eggert wrote:
> On Mon, 31 Dec 2007, David Miller wrote:
> > From: Bodo Eggert <7eggert@gmx.de>
> 
> > > As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> > > on normal systems. This is especially true since udev needs these sockets
> > > and fails to run if UNIX=m.
> > > 
> > > Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
> > 
> > People who use udev can make sure they have it built into their kernel
> > if they have such a dependency.
> > 
> > Not everyone uses udev, and therefore needs AF_UNIX non-modular.
> 
> That's why I kept this option for embedded folks.
> 
> Is there any benefit for non-embedded systems from having UNIX=m?

udev-free != embedded.
