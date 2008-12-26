From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/9] mlx4_en: Removed TX locking when
	polling TX cq
Date: Thu, 25 Dec 2008 18:16:16 -0800 (PST)
Message-ID: <20081225.181616.195227579.davem@davemloft.net>
References: <494F6536.6040107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	jeff@garzik.org
To: yevgenyp@mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <494F6536.6040107@mellanox.co.il>
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
Date: Mon, 22 Dec 2008 12:00:22 +0200

> There is no need to synchronize the polling with the transmit
> function. The only place to synchronize is when we process
> the cq from the transmit function. Also removed spin_lock_irq,
> and using spin_trylock, if somebody else is already processing the cq,
> no need to wait for it to finish.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
