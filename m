From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-acpi] [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Tue, 05 May 2015 18:12:06 +0200
Message-ID: <8157862.NJP1L4Rh25@wuerfel>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <5126612.k0u2CL2zi5@wuerfel> <5548EB42.5010800@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	linux-arm-kernel@lists.infradead.org, herbert@gondor.apana.org.au,
	catalin.marinas@arm.com, rjw@rjwysocki.net,
	linux-kernel@vger.kernel.org, will.deacon@arm.com,
	linux-crypto@vger.kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, lenb@kernel.org
To: linaro-acpi@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5548EB42.5010800@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 05 May 2015 11:09:38 Suravee Suthikulanit wrote:
> 
> However, codes in several places are making use of dma_map_ops without 
> checking if the ops are NULL (i.e. 
> include/asm-generic/dma-mapping-common.h and in arch-specific 
> implementation). If setting it to NULL is what we are planning to 
> support, we would need to scrub the current code to put NULL check. 
> Also, would you consider if that is safe to do going forward?
> 
> 

I mean the dma_mask pointer, not dma_map_ops.

	Arnd
