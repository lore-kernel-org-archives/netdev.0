From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 3.0-rc1: DMAR errors from iwlagn
Date: Wed, 01 Jun 2011 16:34:04 -0700
Message-ID: <4DE6CC6C.7000703@goop.org>
References: <4DE55A26.6040702@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE55A26.6040702@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: linux-wireless

On 05/31/2011 02:14 PM, Jeremy Fitzhardinge wrote:
> I have a Lenovo X220 with:
>
> 03:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300 (rev 35)
> 	Subsystem: Intel Corporation Centrino Ultimate-N 6300 3x3 AGN
> 	Flags: bus master, fast devsel, latency 0, IRQ 50
> 	Memory at d2500000 (64-bit, non-prefetchable) [size=8K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: iwlagn
> 	Kernel modules: iwlagn
>
> With 3.0-rc1, I'm seeing these in dmesg:
>
> DRHD: handling fault status reg 2
> DMAR:[DMA Write] Request device [03:00.0] fault addr ffe8a000 
> DMAR:[fault reason 05] PTE Write access is not set
> DRHD: handling fault status reg 2
> DMAR:[DMA Write] Request device [03:00.0] fault addr ffd5a000 
> DMAR:[fault reason 05] PTE Write access is not set
> DRHD: handling fault status reg 2
> DMAR:[DMA Write] Request device [03:00.0] fault addr ffd52000 
> DMAR:[fault reason 05] PTE Write access is not set
>
> but the device seems to be working OK.
>
> Thanks,
> 	J
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
