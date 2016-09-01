From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch v3 09/11] net: ethernet: xilinx: Enable emaclite for MIPS
Date: Thu, 1 Sep 2016 13:54:35 +0300
Message-ID: <52b2d771-7490-efcc-734f-2caaad6c35e4@cogentembedded.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-10-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net, marc.zyngier@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472661352-11983-10-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/31/2016 7:35 PM, Zubair Lutfullah Kakakhel wrote:

> The MIPS based xilfpga platform uses this driver.
> Enable it for MIPS
>
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

[...]

> diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
> index 4f5c024..ae5c404 100644
> --- a/drivers/net/ethernet/xilinx/Kconfig
> +++ b/drivers/net/ethernet/xilinx/Kconfig
> @@ -5,7 +5,7 @@
>  config NET_VENDOR_XILINX
>  	bool "Xilinx devices"
>  	default y
> -	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ
> +	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ || MIPS
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
>
> @@ -18,7 +18,7 @@ if NET_VENDOR_XILINX
>
>  config XILINX_EMACLITE
>  	tristate "Xilinx 10/100 Ethernet Lite support"
> -	depends on (PPC32 || MICROBLAZE || ARCH_ZYNQ)
> +	depends on (PPC32 || MICROBLAZE || ARCH_ZYNQ || MIPS)

    Parens not needed here, you could remove them while at it.

[...]

MBR, Sergei
