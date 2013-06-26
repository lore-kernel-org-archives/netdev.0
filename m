From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arc_emac: fix compile-time errors & warnings on PPC64
Date: Wed, 26 Jun 2013 01:36:11 -0700 (PDT)
Message-ID: <20130626.013611.177497936507567378.davem@davemloft.net>
References: <1372232966-11507-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy.shevchenko@gmail.com,
	romieu@fr.zoreil.com, joe@perches.com, Vineet.Gupta1@synopsys.com,
	Mischa.Jonker@synopsys.com, arnd@arndb.de, grant.likely@linaro.org,
	rob.herring@calxeda.com, paul.gortmaker@windriver.com,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	florian@openwrt.org, david.laight@aculab.com
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372232966-11507-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed, 26 Jun 2013 11:49:26 +0400

> As reported by "kbuild test robot" there were some errors and warnings
> on attempt to build kernel with "make ARCH=powerpc allmodconfig".
> 
> And this patch addresses both errors and warnings.
> Below is a list of introduced changes:
> 1. Fix compile-time errors (misspellings in "dma_unmap_single") on PPC.
> 2. Use DMA address instead of "skb->data" as a pointer to data buffer.
> This fixed warnings on pointer to int conversion on 64-bit systems.
> 3. Re-implemented initial allocation of Rx buffers in "arc_emac_open" in
> the same way they're re-allocated during operation (receiving packets).
> So once again DMA address could be used instead of "skb->data".
> 4. Explicitly use EMAC_BUFFER_SIZE for Rx buffers allocation.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Applied.
