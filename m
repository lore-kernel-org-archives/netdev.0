From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 18:06:20 +0800
Message-ID: <AANLkTilbAnR1V9DRNAjtfejwNMzXK5tTnRclOrJYGUx9@mail.gmail.com>
References: <27901279770680@web67.yandex.ru> <1279781811.2405.15.camel@edumazet-laptop>
	<AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com>
	<1279791964.2467.12.camel@edumazet-laptop> <AANLkTimLZG_-4wbKy8nrajHVKQvvGtRKEd8qHNoU3swJ@mail.gmail.com>
	<1279792792.2467.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1279792792.2467.15.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 22, 2010 at 5:59 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 22 juillet 2010 =E0 17:52 +0800, Changli Gao a =E9crit :
>
>>
>> FYI: the random option is documented in the manual page of iptables.
>>
>> =A0 =A0REDIRECT
>> =A0 =A0 =A0 =A0This =A0target is only valid in the nat table, in the=
 PREROUTING and OUT-
>> =A0 =A0 =A0 =A0PUT chains, and user-defined chains which are only =A0=
called =A0from =A0those
>> =A0 =A0 =A0 =A0chains. =A0 It redirects the packet to the machine it=
self by changing the
>> =A0 =A0 =A0 =A0destination IP =A0to =A0the =A0primary =A0address =A0=
of =A0the =A0incoming =A0interface
>> =A0 =A0 =A0 =A0(locally-generated packets are mapped to the 127.0.0.=
1 address).
>>
>> =A0 =A0 =A0 =A0--to-ports port[-port]
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 This =A0specifies =A0a =A0destination =A0=
port =A0or range of ports to use:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 without this, the destination port is ne=
ver =A0altered. =A0 This =A0is
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 only valid if the rule also specifies -p=
 tcp or -p udp.
>>
>> =A0 =A0 =A0 =A0--random
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 If =A0option --random is used then port =
mapping will be randomized
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (kernel >=3D 2.6.22).
>>
>>
>
> Note my patch has nothing to do with the man page, its already up2dat=
e.
>
> I usually dont read the Fine manuals, do you ?

Yea. And I don't object your patch. so I add FYI. Thanks.

>
> Try :
>
> iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --help
>
> REDIRECT target options:
> =A0--to-ports <port>[-<port>]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Port (=
range) to map to.
>
>
> You see [--random] is missing.
>
>


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
