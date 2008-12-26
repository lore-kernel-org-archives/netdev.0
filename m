From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 9/9] mlx4_en: Multi queue support
Date: Thu, 25 Dec 2008 18:23:17 -0800 (PST)
Message-ID: <20081225.182317.28395960.davem@davemloft.net>
References: <494F6584.2030304@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	jeff@garzik.org
To: yevgenyp@mellanox.co.il
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <494F6584.2030304@mellanox.co.il>
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
Date: Mon, 22 Dec 2008 12:01:40 +0200

> Added a function that performs hashing on the TX traffic.
> The hashing is only done for TCP or UDP packets, all other packets
> are sent to a default queue.
> We use an indirection table with an entry for each hash result.
> For each entry in the table, we hold statistics regarding the stream
> that corresponds to that entry. Packets are then directed to a TX queue
> according to stream's pattern.
> A ring is opened for each queue.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Also doesn't apply because patches 4, 7, and 8 did not.
