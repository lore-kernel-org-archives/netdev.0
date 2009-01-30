From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Change uec phy id to the same format as
 gianfar's
Date: Thu, 29 Jan 2009 17:28:16 -0800 (PST)
Message-ID: <20090129.172816.174153340.davem@davemloft.net>
References: <1233254342-8435-1-git-send-email-Haiying.Wang@freescale.com>
	<FD1B55B4-574B-4B77-889D-FD81D77DCA5E@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Haiying.Wang@freescale.com
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754347AbZA3B2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:28:19 -0500
In-Reply-To: <FD1B55B4-574B-4B77-889D-FD81D77DCA5E@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Thu, 29 Jan 2009 12:42:38 -0600

> 
> On Jan 29, 2009, at 12:39 PM, Haiying Wang wrote:
> 
> > The commit b31a1d8b41513b96e9c7ec2f68c5734cef0b26a4 changes the gianfar's phy id to
> > the format like "mdio@xxxx:xx", but uec still uses the old format like "xxxxxxxx:xx".
> > For the board whose UEC uses gianfar-mdio like MPC8568MDS, the phy can not be attached
> > because of the incompatible phy id format. This patch changes uec's phy id to the same
> > format as gianfar's.
> >
> > Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> > ---
> > drivers/net/ucc_geth.c           |   20 ++++++++++++++++++--
> > drivers/net/ucc_geth.h           |    2 ++
> > drivers/net/ucc_geth_mii.c       |   12 +++++++++++-
> > drivers/net/ucc_geth_mii.h       |    1 +
> > 4 files changed, 32 insertions(+), 3 deletions(-)
> 
> David,
> 

Applied to net-2.6, thanks.
