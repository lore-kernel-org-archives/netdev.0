From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Mon, 8 Feb 2016 02:18:10 +0900
Message-ID: <CAH1o70Lr8sscPv7nd1JuCwsCt=+v9KeQ08aAP8gW+M0GLkq3tw@mail.gmail.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
	<56AA552B.9080608@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <56AA552B.9080608@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-01-29 2:51 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> On 01/24/2016 06:52 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (descriptor, error, management)
>
>
>    Looking at the code again, ravb_multi_interrupot() only handles error and
> gPTP interrupt now.

Indeed, it is.

>
>> - One interrupt for emac
>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>> This patch improve efficiency of the interrupt handler by adding the
>> interrupt handler corresponding to each interrupt source described
>> above. Additionally, it reduces the number of times of the access to
>> EthernetAVB IF.
>
>
>    I'd still like to see there a statement about not being dependent on the
> whim of a boot loader any more...

I agreed.

>
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
> [...]
>
> MBR, Sergei
>

Thanks,
kaneko
