From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH v3 00/17] net: RDS updates
Date: Tue, 03 Jan 2017 09:46:02 -0500 (EST)
Message-ID: <20170103.094602.1386886488315656207.davem@davemloft.net>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Mon,  2 Jan 2017 14:45:35 -0800

> v2->v3:
> - Re-based against latest net-next head.
> - Dropped a user visible change after discussing with David Miller.
>   It needs some more work to fully support old/new tools matrix.
> - Addressed Dave's comment about bool usage in patch
>   "RDS: IB: track and log active side..." 
> 
> v1->v2:
> Re-aligned indentation in patch 'RDS: mark few internal functions..."
> 
> Series consist of:
>  - RDMA transport fixes for map failure, listen sequence, handler panic and
>    composite message notification.
>  - Couple of sparse fixes.
>  - Message logging improvements for bind failure, use once mr semantics
>    and connection remote address, active end point.
>  - Performance improvement for RDMA transport by reducing the post send
>    pressure on the queue and spreading the CQ vectors.
>  - Useful statistics for socket send/recv usage and receive cache usage.
>  - Additional RDS CMSG used by application to track the RDS message
>    stages for certain type of traffic to find out latency spots.
>    Can be enabled/disabled per socket.
>     
> Series generated against 'net-next'. Full patchset is also available on
> below git tree.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.11/net-next/rds_v3

Pulled, thanks.
