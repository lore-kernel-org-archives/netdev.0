From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [Patch v4 01/12] microblaze: irqchip: Move intc driver to irqchip
Date: Fri, 2 Sep 2016 12:48:28 +0000
Message-ID: <20160902124828.GI10637@io.lakedaemon.net>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
 <772f883f-79fe-9197-f27c-3ffe91019aaf@xilinx.com>
 <5d98fd3b-4722-cdd3-4540-c1d1fec1c98c@imgtec.com>
 <4931182d-7b30-582f-f291-5be59b6b89e4@xilinx.com>
 <03e1ee8a-3053-8823-751d-7513b0e316dc@imgtec.com>
 <6c47c2fd-016e-fe88-ddcb-43d42ed5dbb1@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        marc.zyngier@arm.com, soren.brinkmann@xilinx.com,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6c47c2fd-016e-fe88-ddcb-43d42ed5dbb1@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michal,

On Fri, Sep 02, 2016 at 02:06:40PM +0200, Michal Simek wrote:
> On 2.9.2016 13:46, Zubair Lutfullah Kakakhel wrote:
> > On 09/02/2016 11:27 AM, Michal Simek wrote:
> >> On 2.9.2016 12:06, Zubair Lutfullah Kakakhel wrote:
> >>> On 09/02/2016 07:25 AM, Michal Simek wrote:
> >>>> On 1.9.2016 18:50, Zubair Lutfullah Kakakhel wrote:
> >>>>> V1 -> V2
> >>>>>
> >>>>> Renamed irq-xilinx to irq-axi-intc
> >>>>> Renamed CONFIG_XILINX_INTC to CONFIG_XILINX_AXI_INTC
> >>>>
> >>>>
> >>>> I see that this was suggested by Jason Cooper but using axi name
> >>>> here is
> >>>> not correct.
> >>>> There is xps-intc name which is the name used on old OPB hardware
> >>>> designs. It means this driver can be still used only on system which
> >>>> uses it.
> >>>
> >>> Wouldn't axi-intc be more suitable moving forwards?
> >>> The IP block is now known as axi intc for 5 years as far as I can tell.
> >>>
> >>> Searching "axi intc" online results in the right docs for current and
> >>> future platforms.

Please add links to the relevant docs in the comments of the code.

> >>
> >> yes but we still should support older platform and it is more then this.
> >> This is soft-IP core and in future when there is new bus then IP will
> >> just change bus interface, etc.
> > 
> > That makes sense. I'll rename the driver to irq-xps-intc.c
> > and CONFIG_XILINX_XPS_INTC
> > 
> > Please shout now if anybody has issues with this.
> 
> XPS was shortcut for design tools. You had CONFIG_XILINX_INTC which is
> IMHO the best name you can have.

Michal, thanks for the background info!

Zubair, any problem with CONFIG_XILINX_INTC/irq-xilinx-intc.c ?

thx,

Jason.
