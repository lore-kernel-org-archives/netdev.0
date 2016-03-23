From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH v8 net-next] ravb: Add dma queue interrupt support
Date: Thu, 24 Mar 2016 08:07:15 +0900
Message-ID: <CAH1o70LC=nt1i17zw8rTH-2MppxrcqNXt-qrgUTAiXgctHEVFA@mail.gmail.com>
References: <1458660120-23594-1-git-send-email-ykaneko0929@gmail.com>
	<20160322.155555.77700411133852493.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160322.155555.77700411133852493.davem@redhat.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-23 4:55 GMT+09:00 David Miller <davem@redhat.com>:
> From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Date: Wed, 23 Mar 2016 00:22:00 +0900
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
>>  interrupt handler instead of dma queue interrupt handler]
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
> Sorry, it is not appropriate to submit new features and major optimizations
> at this time.
>
> Please wait until some reasonable time after the merge window closes to
> resubmit this.

I'm sorry to bother you.
I will re-post this patch after net-next reopened.

>
> Thanks.

Best regards,
kaneko
