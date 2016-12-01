From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Thu, 1 Dec 2016 20:40:36 +0300
Message-ID: <7d50b5e0-ae7c-a39d-625a-c9cfc11e398f@cogentembedded.com>
References: <20161201140642.28583-1-chris.brandt@renesas.com>
 <228704e3-fe33-1c1f-61a1-7db451af5faf@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <228704e3-fe33-1c1f-61a1-7db451af5faf@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2016 08:36 PM, Sergei Shtylyov wrote:

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
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    One thing you've missed so far is mentioning R7S72100 (RZ/A1) in the 
subject. This driver supports many SoCs, you're only fixing one of them...

MBR, Sergei
