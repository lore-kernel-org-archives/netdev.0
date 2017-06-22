From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,2/2] hv_netvsc: Fix the carrier state error
 when data path is off
Date: Thu, 22 Jun 2017 13:30:56 -0400 (EDT)
Message-ID: <20170622.133056.934912791314345535.davem@davemloft.net>
References: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
        <1498088447-27282-2-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498088447-27282-2-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Wed, 21 Jun 2017 16:40:47 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> When the VF NIC is opened, the synthetic NIC's carrier state is set to
> off. This tells the host to transitions data path to the VF device. But
> if startup script or user manipulates the admin state of the netvsc
> device directly for example:
>         # ifconfig eth0 down
> 	# ifconfig eth0 up
> Then the carrier state of the synthetic NIC would be on, even though the
> data path was still over the VF NIC. This patch sets the carrier state
> of synthetic NIC with consideration of the related VF state.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
