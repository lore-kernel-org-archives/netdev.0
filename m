From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [Patch v4 01/12] microblaze: irqchip: Move intc driver to irqchip
Date: Fri, 2 Sep 2016 13:28:06 +0000
Message-ID: <20160902132806.GK10637@io.lakedaemon.net>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
 <772f883f-79fe-9197-f27c-3ffe91019aaf@xilinx.com>
 <5d98fd3b-4722-cdd3-4540-c1d1fec1c98c@imgtec.com>
 <4931182d-7b30-582f-f291-5be59b6b89e4@xilinx.com>
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
In-Reply-To: <4931182d-7b30-582f-f291-5be59b6b89e4@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michal, Zubair,

On Fri, Sep 02, 2016 at 12:27:54PM +0200, Michal Simek wrote:
> On 2.9.2016 12:06, Zubair Lutfullah Kakakhel wrote:
> > On 09/02/2016 07:25 AM, Michal Simek wrote:
...
> >> Also there is another copy of this driver in the tree which was using
> >> old ppc405 and ppc440 xilinx platforms.
> >>
> >> arch/powerpc/include/asm/xilinx_intc.h
> >> arch/powerpc/sysdev/xilinx_intc.c
> >>
> >> These should be also removed by moving this driver to generic folder.
> > 
> > I didn't know about that drivers existence.
> > 
> > This patch series already touches microblaze, mips and irqchip.
> > Both microblaze and mips platforms using this driver are little-endian.
> 
> MB is big ending too and as you see there is big endian support in the
> driver already.
> 
> > 
> > Adding a big-endian powerpc driver + platform to the mix is going to
> > complicate the series further and make it super hard to synchronize
> > various subsystems, test stuff, and then move the drivers without
> > breakage.

The whole point of Linus' push to move drivers out of arch/ is to
reduce code duplication and create more robust drivers.

> > I'd highly recommend letting this move happen. And then the powerpc
> > driver can transition over time to this driver.

I've seen this argument before, and despite everyone's best intentions,
it never happens. :(

We have linux-next, 0-day and other resources to test these sorts of
changes and catch errors before they hit mainline.

Let's take our time and do it right.

thx,

Jason.
