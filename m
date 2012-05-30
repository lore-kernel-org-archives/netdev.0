From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/2] r6040: Do a Proper deinit at errorpath and also
 when driver unloads (calling r6040_remove_one)
Date: Tue, 29 May 2012 22:31:39 -0400 (EDT)
Message-ID: <20120529.223139.1478035863626187036.davem@davemloft.net>
References: <1338335014-14877-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338335014-14877-1-git-send-email-devendra.aaru@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Wed, 30 May 2012 05:13:34 +0530

> so if mdiobus_alloc fails, the errorpath doesnt do a netif_napi_del and also
> doesn't set the priv data of the driver to NULL.
> 
> at the driver unload stage the driver doesn't remove the NAPI context, and
> doesnt' set the priv data to NULL, and also doesn't call the pci_iounmap.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
