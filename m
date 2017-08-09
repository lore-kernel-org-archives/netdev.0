From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rds: Reintroduce statistics counting
Date: Tue, 08 Aug 2017 21:04:24 -0700 (PDT)
Message-ID: <20170808.210424.1601241755004039630.davem@davemloft.net>
References: <20170808091332.5413-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org, knut.omang@oracle.com,
        wei.lin-guay@oracle.com
To: Haakon.Bugge@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808091332.5413-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Håkon Bugge <Haakon.Bugge@oracle.com>
Date: Tue,  8 Aug 2017 11:13:32 +0200

> In commit 7e3f2952eeb1 ("rds: don't let RDS shutdown a connection
> while senders are present"), refilling the receive queue was removed
> from rds_ib_recv(), along with the increment of
> s_ib_rx_refill_from_thread.
> 
> Commit 73ce4317bf98 ("RDS: make sure we post recv buffers")
> re-introduces filling the receive queue from rds_ib_recv(), but does
> not add the statistics counter. rds_ib_recv() was later renamed to
> rds_ib_recv_path().
> 
> This commit reintroduces the statistics counting of
> s_ib_rx_refill_from_thread and s_ib_rx_refill_from_cq.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>
> Reviewed-by: Wei Lin Guay <wei.lin.guay@oracle.com>

Applied.
