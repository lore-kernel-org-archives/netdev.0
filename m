From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: match those routes that have different metirc
Date: Mon, 11 Nov 2013 16:29:26 +0800
Message-ID: <52809566.8050908@cn.fujitsu.com>
References: <52804865.8090206@cn.fujitsu.com> <20131111060753.GA27030@order.stressinduktion.org> <52808448.3020206@cn.fujitsu.com> <20131111073923.GB27030@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:14080 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750919Ab3KKIbp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 03:31:45 -0500
In-Reply-To: <20131111073923.GB27030@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B411=E6=9C=8811=E6=97=A5 15:39, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Mon, Nov 11, 2013 at 03:16:24PM +0800, Duan Jiong wrote:
>> =E4=BA=8E 2013=E5=B9=B411=E6=9C=8811=E6=97=A5 14:07, Hannes Frederic=
 Sowa =E5=86=99=E9=81=93:
>>> On Mon, Nov 11, 2013 at 11:00:53AM +0800, Duan Jiong wrote:
>>>> Now the kernel only match those routes that have the same
>>>> metirc, so if those routes are non-reachable, then the packets
>>>> can't be sent out.
>>>>
>>>> But according to the rfc 4191 section 3.2, if the best route
>>>> points to a non-reachable route, the next best route should be
>>>> consulted. So the kernel should not only match those routes that
>>>> have minimum metric, and should also match others.
>>>
>>> I am not so keen on chaning how metrics get handled. Please note th=
at
>>> metrics are a pure linux-centric concept and are not standardized. =
I bet
>>> some people depend on how these work and have the same semantic as =
IPv4
>>> ones because they use the same code in their routing daemon backend=
s.
>>>
>>
>> I have a question. If we only match those routes that have lowest me=
tric, others
>> will never be used, so why the other routes are inserted to the rout=
er table?
>=20
> Metrics could get used by software which manages dynamic interfaces, =
e.g.
> vpn/ppp software, to make sure they have priority over the current ro=
uting
> settings.  If we don't respect metrics there, this could lead to secu=
rity
> problems. (if the interface vanishes, the other route gets active aga=
in).
>=20
> It could also be used by dynamic routing software, e.g. is-is, ospf, =
bgp and
> does reflect the admins choice where traffic should get routed. Some =
routing
> daemon apply the whole routing table to the fib. If we don't respect =
metrics
> there, they could lose money, because maybe they pay for the traffic.
> They really get interesting if you have more than one routing protoco=
l active
> at the same time. ;)
>=20

Thanks for your reply. I think i don't fully understand the metric, and=
 this=20
patch should be ignored!

I am sorry that bothers your.

Thanks,
  Duan
