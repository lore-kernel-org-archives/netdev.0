From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general][PATCH] mlx4: FIX error flow when initializing EQ
	table
Date: Mon, 08 Jun 2009 00:40:07 -0700 (PDT)
Message-ID: <20090608.004007.186996388.davem@davemloft.net>
References: <4A2BD9B9.6000802@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, cl@linux-foundation.org,
	general@lists.openfabrics.org
To: yevgenyp@mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4A2BD9B9.6000802@mellanox.co.il>
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
Date: Sun, 07 Jun 2009 18:16:09 +0300

> If mlx4_create_eq() would fail for one of EQ's assigned for
> completion handling, the code would try to free the same EQ
> we failed to create.
> The crash was found by Christoph Lameter
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks.
