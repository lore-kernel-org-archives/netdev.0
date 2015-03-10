From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: avoid potential stack overflow
Date: Mon, 09 Mar 2015 22:41:18 -0400 (EDT)
Message-ID: <20150309.224118.1760532839925378471.davem@davemloft.net>
References: <17806664.ym3oszzFIH@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	roland@purestorage.com, sowmini.varadhan@oracle.com,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17806664.ym3oszzFIH@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 09 Mar 2015 13:06:52 +0100

> The rds_iw_add_conn function stores a large 'struct rds_sock' object
> on the stack in order to pass a pair of addresses.

As Sowmini pointed out, this function is not the top-level
guilty one, it's rds_iw_update_cm_id.

Please respin this with a corrected commit message, thanks.
