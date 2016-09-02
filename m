From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [Patch v4 01/12] microblaze: irqchip: Move intc driver to irqchip
Date: Fri, 2 Sep 2016 08:25:16 +0200
Message-ID: <772f883f-79fe-9197-f27c-3ffe91019aaf@xilinx.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1.9.2016 18:50, Zubair Lutfullah Kakakhel wrote:
> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
> based xilfpga platform.
> 
> Move the interrupt controller code out of arch/microblaze so that
> it can be used by everyone
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V3 -> V4
> No change
> 
> V2 -> V3
> No change here. Cleanup patches follow after this patch.
> Its debatable to cleanup before/after move. Decided to place cleanup
> after move to put history in new place.
> 
> V1 -> V2
> 
> Renamed irq-xilinx to irq-axi-intc
> Renamed CONFIG_XILINX_INTC to CONFIG_XILINX_AXI_INTC


I see that this was suggested by Jason Cooper but using axi name here is
not correct.
There is xps-intc name which is the name used on old OPB hardware
designs. It means this driver can be still used only on system which
uses it.
Also there is another copy of this driver in the tree which was using
old ppc405 and ppc440 xilinx platforms.

arch/powerpc/include/asm/xilinx_intc.h
arch/powerpc/sysdev/xilinx_intc.c

These should be also removed by moving this driver to generic folder.

Thanks,
Michal
