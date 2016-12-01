From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add missing checks for status bits
Date: Thu, 1 Dec 2016 13:12:39 +0300
Message-ID: <185d6cf0-6f46-9e04-a55d-5f13535c513b@cogentembedded.com>
References: <20161130200148.9011-1-chris.brandt@renesas.com>
 <20161201085223.GD18042@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms@verge.net.au>,
        Chris Brandt <chris.brandt@renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161201085223.GD18042@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/1/2016 11:52 AM, Simon Horman wrote:

>> When streaming a lot of data and the RZ can't keep up, some status bits
>> will get set that are not being checked or cleared which cause the
>> following messages and the Ethernet driver to stop working. This
>> patch fixes that issue.
>>
>> irq 21: nobody cared (try booting with the "irqpoll" option)
>> handlers:
>> [<c036b71c>] sh_eth_interrupt
>> Disabling IRQ #21
>>
>> Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
>> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
>
> Hi Chris,
>
> I am wondering if the EESR_FRC but should also be checked.

    EESR.FRC is not an error bit and it's part of EESR_RX_CHECK already.

MBR, Sergei
