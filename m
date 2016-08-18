From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [PATCH 1/9] microblaze: irqchip: Move intc driver to irqchip
Date: Thu, 18 Aug 2016 10:59:22 +0100
Message-ID: <6d594557-f2b2-5b43-1aaa-18ec6b165b5f@imgtec.com>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-2-git-send-email-Zubair.Kakakhel@imgtec.com>
 <20160815152250.GE3353@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
	<marc.zyngier@arm.com>, <linux-mips@linux-mips.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815152250.GE3353@io.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 08/15/2016 04:22 PM, Jason Cooper wrote:
> Hi Zubair,
>
> On Mon, Aug 15, 2016 at 02:55:27PM +0100, Zubair Lutfullah Kakakhel wrote:
>> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
>> based xilfpga platform.
>>
>> Move the interrupt controller code out of arch/microblaze so that
>> it can be used by everyone
>>
>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>> ---
>>  arch/microblaze/Kconfig                                       | 1 +
>>  arch/microblaze/kernel/Makefile                               | 2 +-
>>  drivers/irqchip/Kconfig                                       | 4 ++++
>>  drivers/irqchip/Makefile                                      | 1 +
>>  arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c | 0
>>  5 files changed, 7 insertions(+), 1 deletion(-)
>>  rename arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c (100%)
>
> When you send the next version, please disable rename detection.  The
> driver looks pretty straight forward, but I'd like to take the
> opportunity to clean up the abstraction around read and write.  As well
> as making it easier for everyone to review on-list.

Thanks for the review.

I'll send the v2 in a while.

Regards,
ZubairLK

>
> thx,
>
> Jason.
>
