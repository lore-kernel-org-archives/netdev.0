From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: replace MVPP2_CPU_D_CACHE_LINE_SIZE with
 L1_CACHE_BYTES
Date: Thu, 31 Mar 2016 15:15:42 -0400 (EDT)
Message-ID: <20160331.151542.1145855002785328972.davem@davemloft.net>
References: <1459338821-343-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459338821-343-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Wed, 30 Mar 2016 19:53:41 +0800

> The mvpp2 ip maybe used in SoCs which may have have 64bytes cacheline
> size. Replace the MVPP2_CPU_D_CACHE_LINE_SIZE with L1_CACHE_BYTES.
> 
> And since dma_alloc_coherent() is always cacheline size aligned, so
> remove the align checks.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Applied.
