From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] xen-netfront: Rework the fix for Rx stall during OOM and
 network stress
Date: Wed, 8 Feb 2017 10:08:19 -0500
Message-ID: <e81a8a0a-5364-433b-3c9b-93d6b1680a89@oracle.com>
References: <1486493941-15696-1-git-send-email-vineethp@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kamatam@amazon.com, aliguori@amazon.com, guruanb@amazon.com
To: Vineeth Remanan Pillai <vineethp@amazon.com>, jgross@suse.com,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486493941-15696-1-git-send-email-vineethp@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2017 01:59 PM, Vineeth Remanan Pillai wrote:
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

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
