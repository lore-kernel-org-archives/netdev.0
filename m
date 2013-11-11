From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: match those routes that have different metirc
Date: Mon, 11 Nov 2013 15:16:24 +0800
Message-ID: <52808448.3020206@cn.fujitsu.com>
References: <52804865.8090206@cn.fujitsu.com> <20131111060753.GA27030@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:19199 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751136Ab3KKHS3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 02:18:29 -0500
In-Reply-To: <20131111060753.GA27030@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B411=E6=9C=8811=E6=97=A5 14:07, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Mon, Nov 11, 2013 at 11:00:53AM +0800, Duan Jiong wrote:
>> Now the kernel only match those routes that have the same
>> metirc, so if those routes are non-reachable, then the packets
>> can't be sent out.
>>
>> But according to the rfc 4191 section 3.2, if the best route
>> points to a non-reachable route, the next best route should be
>> consulted. So the kernel should not only match those routes that
>> have minimum metric, and should also match others.
>=20
> I am not so keen on chaning how metrics get handled. Please note that
> metrics are a pure linux-centric concept and are not standardized. I =
bet
> some people depend on how these work and have the same semantic as IP=
v4
> ones because they use the same code in their routing daemon backends.
>=20

I have a question. If we only match those routes that have lowest metri=
c, others
will never be used, so why the other routes are inserted to the router =
table?

Thanks,
  Duan

> Also, I think it is better targetted for net-next, which is currently=
 closed.
> So we have some time to discuss. ;)
>=20
> Greetings,
>=20
>   Hannes
>=20
>=20
