From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 22 Aug 2016 11:51:35 +1000
Message-ID: <20160822115135.6a5e0f19@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c

between commit:

  e0d8b2908696 ("cxgb4: Fixes resource allocation for ULD's in kdump kernel")

from the net tree and commit:

  94cdb8bb993a ("cxgb4: Add support for dynamic allocation of resources for ULD")

from the net-next tree.

I fixed it up (I just used the version form the net-next tree) and can
carry the fix as necessary. This is now fixed as far as linux-next is
concerned, but any non trivial conflicts should be mentioned to your
upstream maintainer when your tree is submitted for merging.  You may
also want to consider cooperating with the maintainer of the conflicting
tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
