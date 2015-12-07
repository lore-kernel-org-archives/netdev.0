From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH net] ravb: Remove clear unhandled interrupt
Date: Tue, 8 Dec 2015 01:59:15 +0900
Message-ID: <CAH1o70LeSfwpcFicV=CCip=W1QOeYE3VioEv7L-XZCyMBgnTrA@mail.gmail.com>
References: <1449402140-24272-1-git-send-email-ykaneko0929@gmail.com>
	<566489E8.8040605@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <566489E8.8040605@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

2015-12-07 4:18 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/06/2015 02:42 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> AVB-DMAC Reception Warning interrupt is not enabled, so it is not
>> necessary to clear the interrupt.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
>    In principle I agree but perhaps we should clear RIC1 in probe() to not
> depend on a state left from a bootloader?

I think that it is a good idea.
I'll add it to v2.

>
> MBR, Sergei
>

Thanks,
Kaneko
