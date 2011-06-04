From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Sat, 04 Jun 2011 14:04:47 +0200
Message-ID: <4DEA1F5F.4070707@ahsoftware.de>
References: <4DE93422.3070000@ahsoftware.de>	 <1307129642.2600.2.camel@edumazet-laptop>  <4DE93B31.8040700@ahsoftware.de> <1307130914.2600.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307130914.2600.12.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.06.2011 21:55, schrieb Eric Dumazet:
> Le vendredi 03 juin 2011 =C3=A0 21:51 +0200, Alexander Holler a =C3=A9=
crit :
>> Hello,
>>
>> Am 03.06.2011 21:34, schrieb Eric Dumazet:
>>>>
>>>> Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
>>>> should prevent, it introduces NULL a dereference.
>>>>
>>>
>>> I cant find this commit in known trees. Could you give the real com=
mit
>>> id and its title ?
>>
>> Sorry, I haven't seen that question at first. This is the real commi=
t id
>> as found in the stable tree for 2.6.39. The title of that commit is
>> "bridge: initialize fake_rtable metrics"
>
> OK, its commit id is 33eb9873a283a2076f2b5628813d5365ca420ea9
>
> Please always use linux-2.6 tree commits, this saves a lot of time.

Sorry to have wasted your time with posting a full breakdown of the bug=
=20
and a possible solution. I didn't know that stable trees are unknown to=
=20
kernel developers and I did'nt know that the "upstream commit id" in=20
comments of commits in the stable tree are referencing to commit ids in=
=20
Linus tree.

Anyway, I've used the broken way of not using git send-email because I'=
m=20
unsure if the solution I've offered is the best one. I'm lacking the=20
knowledge about what cow_metrics() does, what it is used for, and what,=
=20
if any, pre- or post-requisites are needed to use dst_cow_metrics_gener=
ic().

I can only say that my solution seems to work here, the machine comes u=
p=20
without an oops and I didn't have seen any other problems while using=20
the bridge (which surely doesn't say anything, e.g. I'm not sure if my=20
use of dst_cow_metrics_generic() may introduce a mem leak or similiar,=20
it doesn't look so, but who knows).

Regards,

Alexander
