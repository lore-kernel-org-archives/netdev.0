From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] rds: Reintroduce statistics counting
Date: Tue, 8 Aug 2017 09:41:39 -0700
Message-ID: <5d640216-c9e9-6991-f991-507e2774a74a@oracle.com>
References: <20170808091332.5413-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
        knut.omang@oracle.com, wei.lin-guay@oracle.com
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19389 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdHHQlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:41:09 -0400
In-Reply-To: <20170808091332.5413-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/2017 2:13 AM, Håkon Bugge wrote:
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
> ---
Looks fine.
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
