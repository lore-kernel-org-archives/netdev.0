From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] rds: Fix incorrect statistics counting
Date: Thu, 07 Sep 2017 20:07:33 -0700 (PDT)
Message-ID: <20170907.200733.1562967291105061977.davem@davemloft.net>
References: <20170906163551.20387-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org, knut.omang@oracle.com
To: Haakon.Bugge@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906163551.20387-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Håkon Bugge <Haakon.Bugge@oracle.com>
Date: Wed,  6 Sep 2017 18:35:51 +0200

> In rds_send_xmit() there is logic to batch the sends. However, if
> another thread has acquired the lock and has incremented the send_gen,
> it is considered a race and we yield. The code incrementing the
> s_send_lock_queue_raced statistics counter did not count this event
> correctly.
> 
> This commit counts the race condition correctly.
> 
> Changes from v1:
> - Removed check for *someone_on_xmit()*
> - Fixed incorrect indentation
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>

Applied.
