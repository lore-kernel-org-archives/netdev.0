From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] dwc_eth_qos: stability fixes and support for
 CMA
Date: Wed, 02 Mar 2016 15:01:47 -0500 (EST)
Message-ID: <20160302.150147.1268791264778527540.davem@davemloft.net>
References: <cover.1456756740.git.larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	larper@axis.com
To: lars.persson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson@axis.com>
Date: Mon, 29 Feb 2016 16:22:29 +0100

> This series has bug fixes for the dwc_eth_qos ethernet driver.
> 
> Mainly two stability fixes for problems found by Rabin Vincent:
> - Successive starts and stops of the interface would trigger a DMA reset timeout.
> - A race condition in the TX DMA handling could trigger a netdev watchdog
>  timeout.
> 
> The memory allocation was improved to support use of the CMA as DMA allocator
> backend.

Series applied, thanks.
