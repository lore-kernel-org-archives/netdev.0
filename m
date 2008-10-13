From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Tue, 14 Oct 2008 00:18:38 +0100
Message-ID: <20081013231837.GL6646@trinity.fluff.org>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org> <20081013.030150.96524866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cooloney@kernel.org, ben@simtec.co.uk, s.hauer@pengutronix.de,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jherrero@hvsistemas.es
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.fluff.org ([89.145.97.151]:53817 "EHLO
	trinity.fluff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbYJMXSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 19:18:51 -0400
Content-Disposition: inline
In-Reply-To: <20081013.030150.96524866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 03:01:50AM -0700, David Miller wrote:
> From: Bryan Wu <cooloney@kernel.org>
> Date: Mon, 13 Oct 2008 17:10:09 +0800
> 
> > From: Javier Herrero <jherrero@hvsistemas.es>
> > 
> > Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
> > Signed-off-by: Bryan Wu <cooloney@kernel.org>
> 
> This is not only inelegant, it'll likely break things on
> 64-bit MIPS or any other case where the upper 32-bit matter.
> 
> I'd rather see Blackfin fix it's I/O accessor prototypes
> to take a proper __iomem pointer.

How much would it hurt to provide blackfin wide
readsb and friends with the correct prototype and
remove the nasty blackfin hack in the dm9000.c driver
for good?

-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.
