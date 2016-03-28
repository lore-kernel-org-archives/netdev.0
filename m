From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH v8 net-next] ravb: Add dma queue interrupt support
Date: Mon, 28 Mar 2016 23:32:16 +0900
Message-ID: <CAH1o70LE6UojsYAkAao0M--S+ZcrTPYrvVFitrQT+e29q+znbA@mail.gmail.com>
References: <1458660120-23594-1-git-send-email-ykaneko0929@gmail.com>
	<56F7D9E6.6080605@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56F7D9E6.6080605@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

2016-03-27 22:02 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 03/22/2016 06:22 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (timestamp, error, gPTP)
>> - One interrupt for emac
>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>> This patch improve efficiency of the interrupt handler by adding the
>> interrupt handler corresponding to each interrupt source described
>> above. Additionally, it reduces the number of times of the access to
>> EthernetAVB IF.
>> Also this patch prevent this driver depends on the whim of a boot loader.
>>
>> [ykaneko0929@gmail.com: define bit names of registers]
>> [ykaneko0929@gmail.com: add comment for gen3 only registers]
>> [ykaneko0929@gmail.com: fix coding style]
>> [ykaneko0929@gmail.com: update changelog]
>> [ykaneko0929@gmail.com: gen3: fix initialization of interrupts]
>> [ykaneko0929@gmail.com: gen3: fix clearing interrupts]
>> [ykaneko0929@gmail.com: gen3: add helper function for request_irq()]
>> [ykaneko0929@gmail.com: gen3: remove IRQF_SHARED flag for request_irq()]
>> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
>> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked interrupts]
>> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
>> [ykaneko0929@gmail.com: make timestamp interrupt handler a function]
>> [ykaneko0929@gmail.com: timestamp interrupt is handled in multiple
>>   interrupt handler instead of dma queue interrupt handler]
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
> [...]
>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Many thanks for your review and much help!

>
> MBR, Sergei
>

Thanks,
kaneko
