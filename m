From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: replace MVNETA_CPU_D_CACHE_LINE_SIZE with
 L1_CACHE_BYTES
Date: Thu, 31 Mar 2016 22:37:35 +0200
Message-ID: <20160331223735.32904e42@free-electrons.com>
References: <1459338921-391-1-git-send-email-jszhang@marvell.com>
	<20160331.151547.1889188465826831929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jszhang@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160331.151547.1889188465826831929.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, 31 Mar 2016 15:15:47 -0400 (EDT), David Miller wrote:
> From: Jisheng Zhang <jszhang@marvell.com>
> Date: Wed, 30 Mar 2016 19:55:21 +0800
> 
> > The mvneta is also used in some Marvell berlin family SoCs which may
> > have 64bytes cacheline size. Replace the MVNETA_CPU_D_CACHE_LINE_SIZE
> > usage with L1_CACHE_BYTES.
> > 
> > And since dma_alloc_coherent() is always cacheline size aligned, so
> > remove the align checks.
> > 
> > Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> 
> Applied.

A new version of the patch was sent, which more rightfully uses
cache_line_size(), see:

 "[PATCH v2] net: mvneta: replace MVNETA_CPU_D_CACHE_LINE_SIZE with cache_line_size"

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
