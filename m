From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 19 Feb 2016 09:50:31 +1100
Message-ID: <20160219095031.32105d4c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Clemens Gruber <clemens.gruber@pqgruber.com>,
	Stefan Roese <sr@denx.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/phy/marvell.c

between commit:

  79be1a1c9090 ("phy: marvell: Fix and unify reg-init behavior")

from the net tree and commit:

  930b37ee8d84 ("net: phy: Add SGMII support for Marvell 88E1510/1512/1514/1518")

from the net-next tree.

OK, I didn't know how to resolve this, so I just used the net-next
tree version (which is probably wrong, but will build).

-- 
Cheers,
Stephen Rothwell
