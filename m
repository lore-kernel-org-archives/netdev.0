From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net tree
Date: Fri, 14 Oct 2016 13:12:51 +1100
Message-ID: <20161014131251.6708fcbc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in:

  include/linux/mlx5/device.h

between commit:

  b8a4ddb2e8f4 ("net/mlx5: Add MLX5_ARRAY_SET64 to fix BUILD_BUG_ON")

from the net tree and patch:

  "include/linux/mlx5/device.h: kill BUILD_BUG_ON()s"

from the akpm tree.

I fixed it up (I just dropped the akpm tree patch for today) and can
carry the fix as necessary. This is now fixed as far as linux-next is
concerned, but any non trivial conflicts should be mentioned to your
upstream maintainer when your tree is submitted for merging.  You may
also want to consider cooperating with the maintainer of the conflicting
tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
