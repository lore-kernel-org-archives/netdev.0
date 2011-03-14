From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH net-next-2.6] ftmac100: use GFP_ATOMIC allocations where needed
Date: Mon, 14 Mar 2011 16:16:06 +0800
Message-ID: <AANLkTi=grwkfYpBFJEyQHXbFaTov5Tc+tAR2ebzw0Bht@mail.gmail.com>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
 <1300047388.2761.48.camel@edumazet-laptop> <1300048002.2761.53.camel@edumazet-laptop>
 <1300048193.2761.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62115 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab1CNIQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 04:16:27 -0400
In-Reply-To: <1300048193.2761.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Mar 14, 2011 at 4:29 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 13 mars 2011 =C3=A0 21:26 +0100, Eric Dumazet a =C3=A9cri=
t :
>> Le dimanche 13 mars 2011 =C3=A0 21:16 +0100, Eric Dumazet a =C3=A9cr=
it :
>>
>> > BTW, it seems I missed the fact that ftmac100_alloc_rx_page() used=
 a
>> > GFP_KERNEL allocation, while its called from softirq context (from
>> > ftmac100_rx_packet())
>>
>> Here is a patch against ftmac100
>>
>
> Oops, one typo in it sorry
>
>> -static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftm=
ac100_rxdes *rxdes)
>> +static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ftmac100_rxdes *rxdes, gt=
p_t gfp)
>
> Should be : =C2=A0 gfp_t gfp
>
> Please build and test the patch, I dont have an ARM testbed anyway.

Tested-by: Po-Yu Chuang <ratbert@faraday-tech.com>

Thank you,
Po-Yu Chuang
