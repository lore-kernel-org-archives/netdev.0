From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Fix inaccurate accounting of unsignaled wrs
Date: Thu, 26 Oct 2017 17:36:26 +0900 (KST)
Message-ID: <20171026.173626.1982523888757754892.davem@davemloft.net>
References: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Haakon.Bugge@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Håkon Bugge <Haakon.Bugge@oracle.com>
Date: Tue, 24 Oct 2017 16:16:28 +0200

> The number of unsignaled work-requests posted to the IB send queue is
> tracked by a counter in the rds_ib_connection struct. When it reaches
> zero, or the caller explicitly asks for it, the send-signaled bit is
> set in send_flags and the counter is reset. This is performed by the
> rds_ib_set_wr_signal_state() function.
> 
> However, this function is not always used which yields inaccurate
> accounting. This commit fixes this, re-factors a code bloat related to
> the matter, and makes the actual parameter type to the function
> consistent.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>

Applied.
