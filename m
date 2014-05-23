From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC ipsec-next] xfrm: make sha256 icv truncation length RFC-compliant
Date: Fri, 23 May 2014 10:06:09 +0200
Message-ID: <537F0171.5070902@6wind.com>
References: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com> <1400771437-14096-2-git-send-email-horia.geanta@freescale.com> <537E1FD8.8030504@6wind.com> <537EEAA6.7000506@freescale.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lei Xu <Lei.Xu@freescale.com>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?B?SG9yaWEgR2VhbnTEgw==?= <horia.geanta@freescale.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537EEAA6.7000506@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 23/05/2014 08:28, Horia Geant=C4=83 a =C3=A9crit :
> On 5/22/2014 7:03 PM, Nicolas Dichtel wrote:
>> Le 22/05/2014 17:10, Horia Geanta a =C3=A9crit :
>>> From: Lei Xu <Lei.Xu@freescale.com>
>>>
>>> Currently the sha256 icv truncation length is set to 96bit
>>> while the length is defined as 128bit in RFC4868.
>>> This may result in somer errors when working with other IPsec devic=
es
>>> with the standard truncation length.
>>> Thus, change the sha256 truncation length from 96bit to 128bit.
>> The patch was already proposed, but it was kept as-is for userspace
>> compatibility.
>>
>> See: https://lkml.org/lkml/2012/3/7/431
>
> Thanks, somehow I missed that.
>
> So this just means bad luck for user space tools (for e.g. ipsec-tool=
s - setkey,
> racoon - and any other PF_KEY-based tool) that AFAICT cannot override=
 the
> default truncated icv size, right?
You can change the default value with the netlink attribute
XFRMA_ALG_AUTH_TRUNC (option 'auth-trunc' in iproute2).


Regards,
Nicolas
