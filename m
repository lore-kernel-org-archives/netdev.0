From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [Linaro-acpi] [V2 PATCH 2/5] arm64 : Introduce support for ACPI
 _CCA object
Date: Tue, 5 May 2015 11:13:59 -0500
Message-ID: <5548EC47.3020501@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <5126612.k0u2CL2zi5@wuerfel> <5548EB42.5010800@amd.com>
 <8157862.NJP1L4Rh25@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	<herbert@gondor.apana.org.au>, <catalin.marinas@arm.com>,
	<rjw@rjwysocki.net>, <linux-kernel@vger.kernel.org>,
	<will.deacon@arm.com>, <linux-crypto@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <lenb@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, <linaro-acpi@lists.linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8157862.NJP1L4Rh25@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/5/2015 11:12 AM, Arnd Bergmann wrote:
> On Tuesday 05 May 2015 11:09:38 Suravee Suthikulanit wrote:
>>
>> However, codes in several places are making use of dma_map_ops without
>> checking if the ops are NULL (i.e.
>> include/asm-generic/dma-mapping-common.h and in arch-specific
>> implementation). If setting it to NULL is what we are planning to
>> support, we would need to scrub the current code to put NULL check.
>> Also, would you consider if that is safe to do going forward?
>>
>>
>
> I mean the dma_mask pointer, not dma_map_ops.
>
> 	Arnd
>

Ah, got it. Sorry for confusion.

Suravee
