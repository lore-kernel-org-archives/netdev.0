From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 1/9] microblaze: irqchip: Move intc driver to irqchip
Date: Mon, 15 Aug 2016 15:22:50 +0000
Message-ID: <20160815152250.GE3353@io.lakedaemon.net>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
	marc.zyngier@arm.com, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471269335-58747-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zubair,

On Mon, Aug 15, 2016 at 02:55:27PM +0100, Zubair Lutfullah Kakakhel wrote:
> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
> based xilfpga platform.
> 
> Move the interrupt controller code out of arch/microblaze so that
> it can be used by everyone
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> ---
>  arch/microblaze/Kconfig                                       | 1 +
>  arch/microblaze/kernel/Makefile                               | 2 +-
>  drivers/irqchip/Kconfig                                       | 4 ++++
>  drivers/irqchip/Makefile                                      | 1 +
>  arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c | 0
>  5 files changed, 7 insertions(+), 1 deletion(-)
>  rename arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c (100%)

When you send the next version, please disable rename detection.  The
driver looks pretty straight forward, but I'd like to take the
opportunity to clean up the abstraction around read and write.  As well
as making it easier for everyone to review on-list.

thx,

Jason.
