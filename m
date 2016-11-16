From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] cadence: Add LSO support.
Date: Wed, 16 Nov 2016 17:56:15 -0500 (EST)
Message-ID: <20161116.175615.1225296791248245329.davem@davemloft.net>
References: <1478698862-12924-1-git-send-email-rafalo@cadence.com>
        <1479290554-22123-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479290554-22123-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Wed, 16 Nov 2016 10:02:34 +0000

> New Cadence GEM hardware support Large Segment Offload (LSO):
> TCP segmentation offload (TSO) as well as UDP fragmentation
> offload (UFO). Support for those features was added to the driver.
> ---
> Changed in v2:
> macb_lso_check_compatibility() changed to macb_features_check()
> (with little modifications) and bind to .ndo_features_check.
> (after Eric Dumazet suggestion)
> ---
> Changed in v3:
> Respin to net-next.
> ---
> Changed in v4:
> (struct iphdr*)skb_network_header(skb) changed to ip_hdr(skb)
> ---
> Changed in v5:
> Changes after Florian Fainelli comments
> ---
> Changes in v6:
> UDP checksum zeroing removed. There is no need to zeroing
> UDP checksum during UFO operation.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

Applied.

But you really, truly, screwed up this commit message.

Everything after "---" will be deleted from the commit message when I
apply your patch with GIT.  Which means your entire changelog plus
your signoff were removed.

Please do this properly in the future.
