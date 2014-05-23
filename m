From: =?UTF-8?B?SG9yaWEgR2VhbnTEgw==?= <horia.geanta@freescale.com>
Subject: Re: [RFC ipsec-next] xfrm: make sha256 icv truncation length RFC-compliant
Date: Fri, 23 May 2014 09:28:54 +0300
Message-ID: <537EEAA6.7000506@freescale.com>
References: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com>
 <1400771437-14096-2-git-send-email-horia.geanta@freescale.com>
 <537E1FD8.8030504@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lei Xu <Lei.Xu@freescale.com>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E1FD8.8030504@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/22/2014 7:03 PM, Nicolas Dichtel wrote:
> Le 22/05/2014 17:10, Horia Geanta a =C3=A9crit :
>> From: Lei Xu <Lei.Xu@freescale.com>
>>
>> Currently the sha256 icv truncation length is set to 96bit
>> while the length is defined as 128bit in RFC4868.
>> This may result in somer errors when working with other IPsec device=
s
>> with the standard truncation length.
>> Thus, change the sha256 truncation length from 96bit to 128bit.
> The patch was already proposed, but it was kept as-is for userspace
> compatibility.
>
> See: https://lkml.org/lkml/2012/3/7/431

Thanks, somehow I missed that.

So this just means bad luck for user space tools (for e.g. ipsec-tools =
-=20
setkey, racoon - and any other PF_KEY-based tool) that AFAICT cannot=20
override the default truncated icv size, right?

Thanks,
Horia
