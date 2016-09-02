From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v4 01/12] microblaze: irqchip: Move intc driver to irqchip
Date: Fri, 2 Sep 2016 12:46:20 +0100
Message-ID: <03e1ee8a-3053-8823-751d-7513b0e316dc@imgtec.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
 <772f883f-79fe-9197-f27c-3ffe91019aaf@xilinx.com>
 <5d98fd3b-4722-cdd3-4540-c1d1fec1c98c@imgtec.com>
 <4931182d-7b30-582f-f291-5be59b6b89e4@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4931182d-7b30-582f-f291-5be59b6b89e4@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for the valuable feedback.
Comments inline


On 09/02/2016 11:27 AM, Michal Simek wrote:
> On 2.9.2016 12:06, Zubair Lutfullah Kakakhel wrote:
>> Hi,
>>
>> On 09/02/2016 07:25 AM, Michal Simek wrote:
>>> On 1.9.2016 18:50, Zubair Lutfullah Kakakhel wrote:
>>>> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
>>>> based xilfpga platform.
>>>>
>>>> Move the interrupt controller code out of arch/microblaze so that
>>>> it can be used by everyone
>>>>
>>>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>>>>
>>>> ---
>>>> V3 -> V4
>>>> No change
>>>>
>>>> V2 -> V3
>>>> No change here. Cleanup patches follow after this patch.
>>>> Its debatable to cleanup before/after move. Decided to place cleanup
>>>> after move to put history in new place.
>>>>
>>>> V1 -> V2
>>>>
>>>> Renamed irq-xilinx to irq-axi-intc
>>>> Renamed CONFIG_XILINX_INTC to CONFIG_XILINX_AXI_INTC
>>>
>>>
>>> I see that this was suggested by Jason Cooper but using axi name here is
>>> not correct.
>>> There is xps-intc name which is the name used on old OPB hardware
>>> designs. It means this driver can be still used only on system which
>>> uses it.
>>
>> Wouldn't axi-intc be more suitable moving forwards?
>> The IP block is now known as axi intc for 5 years as far as I can tell.
>>
>> Searching "axi intc" online results in the right docs for current and
>> future platforms.
>
> yes but we still should support older platform and it is more then this.
> This is soft-IP core and in future when there is new bus then IP will
> just change bus interface, etc.

That makes sense. I'll rename the driver to irq-xps-intc.c
and CONFIG_XILINX_XPS_INTC

Please shout now if anybody has issues with this.

Regards,
ZubairLK
