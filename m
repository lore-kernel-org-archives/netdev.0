From: David Miller <davem@davemloft.net>
Subject: Re: [net][PATCH v2 2/2] RDS: Fix the atomicity for congestion map
 update
Date: Sat, 16 Apr 2016 19:01:42 -0400 (EDT)
Message-ID: <20160416.190142.1728042848852620447.davem@davemloft.net>
References: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
	<1460655807-26236-3-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460655807-26236-3-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Thu, 14 Apr 2016 10:43:27 -0700

> Two different threads with different rds sockets may be in
> rds_recv_rcvbuf_delta() via receive path. If their ports
> both map to the same word in the congestion map, then
> using non-atomic ops to update it could cause the map to
> be incorrect. Lets use atomics to avoid such an issue.
> 
> Full credit to Wengang <wen.gang.wang@oracle.com> for
> finding the issue, analysing it and also pointing out
> to offending code with spin lock based fix.
> 
> Reviewed-by: Leon Romanovsky <leon@leon.nu>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied.
