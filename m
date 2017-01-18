From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net-next tree
Date: Wed, 18 Jan 2017 11:37:13 +1100
Message-ID: <20170118113713.43c862b1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) produced these warnings:

drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function 'init_one':
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:9: warning: unused variable 'port_vec' [-Wunused-variable]
  u32 v, port_vec;
         ^
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:6: warning: unused variable 'v' [-Wunused-variable]
  u32 v, port_vec;
      ^
Introduced by commit

  96fe11f27b70 ("cxgb4: Implement ndo_get_phys_port_id for mgmt dev")

-- 
Cheers,
Stephen Rothwell
