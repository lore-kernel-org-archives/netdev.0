From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Rework the fix for Rx stall during OOM
 and network stress
Date: Thu, 09 Feb 2017 16:34:41 -0500 (EST)
Message-ID: <20170209.163441.1292042359985747391.davem@davemloft.net>
References: <1486493941-15696-1-git-send-email-vineethp@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: boris.ostrovsky@oracle.com, jgross@suse.com,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kamatam@amazon.com,
        aliguori@amazon.com, guruanb@amazon.com
To: vineethp@amazon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486493941-15696-1-git-send-email-vineethp@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vineeth Remanan Pillai <vineethp@amazon.com>
Date: Tue, 7 Feb 2017 18:59:01 +0000

> The commit 90c311b0eeea ("xen-netfront: Fix Rx stall during network
> stress and OOM") caused the refill timer to be triggerred almost on
> all invocations of xennet_alloc_rx_buffers for certain workloads.
> This reworks the fix by reverting to the old behaviour and taking into
> consideration the skb allocation failure. Refill timer is now triggered
> on insufficient requests or skb allocation failure.
> 
> Signed-off-by: Vineeth Remanan Pillai <vineethp@amazon.com>
> Fixes: 90c311b0eeea (xen-netfront: Fix Rx stall during network stress and OOM)
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Applied.
