From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: Fix set_max_bgx_per_node for 81xx rgx
Date: Mon, 17 Apr 2017 13:04:17 -0400 (EDT)
Message-ID: <20170417.130417.1899748229201291787.davem@davemloft.net>
References: <1492068301-1141-1-git-send-email-george.cherian@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, rric@kernel.org, sgoutham@cavium.com
To: george.cherian@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492068301-1141-1-git-send-email-george.cherian@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Cherian <george.cherian@cavium.com>
Date: Thu, 13 Apr 2017 07:25:01 +0000

> Add the PCI_SUBSYS_DEVID_81XX_RGX and use the same to set
> the max bgx per node count.
> 
> This fixes the issue intoduced by following commit
> 78aacb6f6 net: thunderx: Fix invalid mac addresses for node1 interfaces
> With this commit the max_bgx_per_node for 81xx is set as 2 instead of 3
> because of which num_vfs is always calculated as zero.
> 
> Signed-off-by: George Cherian <george.cherian@cavium.com>

Applied.
