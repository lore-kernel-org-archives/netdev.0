From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v4 01/12] microblaze: irqchip: Move intc driver to irqchip
Date: Fri, 2 Sep 2016 10:55:01 +0100
Message-ID: <025ed01a-9a56-78cc-02cc-39b8c42f8f63@imgtec.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-2-git-send-email-Zubair.Kakakhel@imgtec.com>
 <33b0c20d-a939-0e26-4443-dc41ba06f250@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:33954 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752517AbcIBJzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 05:55:14 -0400
In-Reply-To: <33b0c20d-a939-0e26-4443-dc41ba06f250@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/02/2016 06:56 AM, Michal Simek wrote:
> On 1.9.2016 18:50, Zubair Lutfullah Kakakhel wrote:
>> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
>> based xilfpga platform.
>>
>> Move the interrupt controller code out of arch/microblaze so that
>> it can be used by everyone
>
> if this is just move that you should setup your git right that it won't
> be remove on one side and add on other side.
>
> It should look like this when git mv is used and git setup is right.

That was how I structured it in the first patch.
However irqchip maintainers requested to not do that and show the entire diff
for cleanup/review.

Regards,
ZubairLK

>
> diff --git a/Makefile b/Makefile2
> similarity index 100%
> rename from Makefile
> rename to Makefile2
>
> Thanks,
> Michal
>
