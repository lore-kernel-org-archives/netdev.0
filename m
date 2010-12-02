From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install time
Date: Thu, 2 Dec 2010 18:10:05 +0800
Message-ID: <AANLkTikkeQNzTMs_AifJFFU3oEKAmMBaCO9PCRWLRTSo@mail.gmail.com>
References: <1291227893.2856.1039.camel@edumazet-laptop> <20101201.104450.183053379.davem@davemloft.net>
 <1291232937.2856.1042.camel@edumazet-laptop> <20101201.122312.229751364.davem@davemloft.net>
 <1291236342.2856.1057.camel@edumazet-laptop> <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
 <1291272384.2856.1074.camel@edumazet-laptop> <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
 <1291280000.2871.16.camel@edumazet-laptop> <1291280402.2871.20.camel@edumazet-laptop>
 <AANLkTikQOY7Nh7XOFT9wXDYpn1faVS9xH2Y-x67hiu7S@mail.gmail.com> <1291283693.2871.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44461 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab0LBKK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 05:10:27 -0500
Received: by fxm20 with SMTP id 20so962219fxm.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 02:10:26 -0800 (PST)
In-Reply-To: <1291283693.2871.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 5:54 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 02 d=E9cembre 2010 =E0 17:10 +0800, Changli Gao a =E9crit :
>>
>> Oops. We were wrong. The RAM of BPF machine is initialized to 0. So
>> loading from a cell, in which no value is stored before, is valid. S=
o
>> we can't prevent the following instructions.
>>
>
> It was not 'initialized to 0', thats the point of previous patches.
>

I checked the implementation of bpf in FreeBSD, and found RAM isn't
initialized to 0. Then it could not be a common 'feature', and no
application relies on it. Maybe we can drop this 'feature' added by
accident, and break the 'ABI'.

Now, I agree with you totally. Thank for your explaining..

Acked-by: Changli Gao <xiaosuo@gmail.com>

>
> (By the way, I believe FreeBSD has the security problem Dan reported =
to us)

Yes. it doesn't do this check.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
