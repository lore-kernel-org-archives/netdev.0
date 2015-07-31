From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 31 Jul 2015 10:35:53 +1000
Message-ID: <20150731103553.5311283a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Karicheri, Muralidharan" <m-karicheri2@ti.com>,
	WingMan Kwok <w-kwok2@ti.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/ti/netcp_ethss.c

between commit:

  31a184b7acbc ("net: netcp: ethss: cleanup gbe_probe() and gbe_remove() functions")

from the net tree and commit:

  489e8a2f09d7 ("net: netcp: Fixes to CPSW statistics collection")

from the net-next tree.

I fixed it up (using the error path from the former) and can carry the
fix as necessary (no action is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
