From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 4/9] mlx4_en: Verify number of RX rings
 doesn't exceed MAX_RX_RINGS
Date: Thu, 25 Dec 2008 18:18:48 -0800 (PST)
Message-ID: <20081225.181848.211823343.davem@davemloft.net>
References: <494F6551.3040500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	jeff@garzik.org
To: yevgenyp@mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <494F6551.3040500@mellanox.co.il>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 22 Dec 2008 12:00:49 +0200

> Required in cases were dev->caps.num_comp_vectors > MAX_RX_RINGS.
> For current values this would happen on machines that have more
> then 16 cores.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

This patch does not apply to the tree.

In fact, there is no reference at all to num_comp_vectors
in the mlx4_en driver at all.  The code there currently reads:

		if (!mdev->profile.prof[i].rx_ring_num) {
			mdev->profile.prof[i].rx_ring_num = 1;
			mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
				  1, i);

So there is some other patch applied to your copy of the driver
already that adds all of that num_comp_vectors stuff.  It isn't
in the upstream sources, and it certainly isn't in the networking
development GIT tree(s), that is for sure.

Please, please (did I say please?), please be more careful
in the future and don't send patches that do not apply properly
to the tree.  This wastes a lot of my time and discourages my
handling your patches efficiently in the future.
