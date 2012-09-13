From: Craig Hada <craig.hada@hp.com>
Subject: Re: [PATCH net-next] drivers/net: Enable IOMMU pass through for be2net
Date: Thu, 13 Sep 2012 10:06:43 -0700
Message-ID: <505212A3.1030307@hp.com>
References: <1347472734-3196-1-git-send-email-craig.hada@hp.com> <4988B24899FF4448BF3D99EFCD2A3562323AD5@G1W3785.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, linux-kernel@vger.kernel.org
To: "Hada, Craig M" <craig.hada@hp.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4988B24899FF4448BF3D99EFCD2A3562323AD5@G1W3785.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/2012 9:27 AM, Hada, Craig M wrote:
> This patch sets the coherent DMA mask to 64-bit after the be2net driver has been acknowledged that the system is 64-bit DMA capable. The coherent DMA mask is examined by the Intel IOMMU driver to determine whether to allow pass through context mapping for all devices. With this patch, the be2net driver combined with be2net compatible hardware provides comparable performance to the case where vt-d is disabled. The main use case for this change is to decrease the time necessary to copy virtual machine memory during KVM live migration instantiations.
>
> This patch was tested on a system that enables the IOMMU in non-coherent mode. Two DMA remapper issues were encountered and both are in the Intel IOMMU driver with the following patches submitted upstream but not yet commited.
>
> Patch 1 - DMAR:[fault reason 02] Present bit in context entry is clear
> https://lkml.org/lkml/2012/6/15/20

My apologies for posting a truncated link for the above. The correct link is https://lkml.org/lkml/2012/6/15/204

-Craig
