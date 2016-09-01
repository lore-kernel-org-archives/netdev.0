From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [Patch v3 03/11] irqchip: axi-intc: Add support for parent intc
Date: Thu, 1 Sep 2016 15:48:18 +0100
Message-ID: <57C83FB2.607@arm.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-4-git-send-email-Zubair.Kakakhel@imgtec.com>
 <57C70C71.3060603@arm.com> <81b5f75c-51b5-0482-50d1-f51c5687edbc@imgtec.com>
 <57C81BB5.3060807@arm.com> <f45ffb5f-fb66-4083-4754-f8e50689216b@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f45ffb5f-fb66-4083-4754-f8e50689216b@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/16 14:52, Zubair Lutfullah Kakakhel wrote:
> Hi,

[...]

>> But that still doesn't address the case I had in mind, which is when you
>> have *two* AXI-intc, one cascaded into the other. Is that something that
>> could be built? You should at least make sure that there is a big fat
>> warning if you don't want to support that case, because that will be
>> hell to debug.
> 
> Oo. I didn't think of that one. tbh, I'm not sure if that is currently supported
> because this driver came out of arch/microblaze. And it didn't have any code that
> looked supportive of chained interrupt handling.
> 
> 'Technically', it should be possible to synthesize two daisy chained axi interrupt
> controllers on an FPGA. But I don't see it being supported before.
> 
> A warning would be nice. Any suggestions on the most suitable way?

Check if you've already allocated a xintc_irqc. If so, abort the probing
early...

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
