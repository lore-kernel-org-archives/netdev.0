From: Chen Gang <gang.chen@asianux.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Tue, 27 Nov 2012 12:45:23 +0800
Message-ID: <50B44563.8060905@asianux.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:3189 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757007Ab2K0Eoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 23:44:30 -0500
In-Reply-To: <50B43F12.1090709@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA11=D4=C227=C8=D5 12:18, Chen Gang =D0=B4=B5=C0:
> =D3=DA 2012=C4=EA11=D4=C227=C8=D5 11:17, Shan Wei =D0=B4=B5=C0:
>> > Chen Gang said, at 2012/11/23 11:35:
>>> >> 2) about %*s:
>>> >>  since kernel is an open system, IFNAMSIZ is belong to OS API le=
vel for outside
>>> >>    it has effect both on individual kernel modules and user mode=
 system call
>>> >>    we need obey this rule, and %8s is not match this rule.
>>> >>    so %8s is not suitable. (and now we have to choose %16s or %s=
).
>> >=20
>> > Your patch will change the format of /proc/net/ipv6_route.
>   Yes, it will be changed.
>   although it belongs to "User Experience", it is not belong to os ap=
i level.
>     for os api level: we must commit them not be changed (they are te=
stament)
>     for User Experience: we can change it, but maybe users feel 'not =
good'.
>=20
  I think (only for my thought, maybe not correct):
    for user input through /proc/* are all for os api level, not for "U=
ser Experience".
    for most of outputs to user through /proc/*, are "User Experience".

>> > Why we need to keep be consistent with user mode?
>   it is for "keep source code simple and clear"
>   when others see the %8s, easy to make them miss understanding (not =
quite clear)
>   so better to change it to %s.
>=20
>=20
>> > However user operates device name, no effect on the showing of /pr=
oc/net/ipv6_route.
>   now, no effect.
>=20
>=20
> all together:
>   since we are not user interactive program,
>     "keeping source code simple and clear" is more important than "Us=
er Experience"
>=20
>=20
>> >=20
>>> >>
>>> >>  for the format of information which seq_printf output:
>>> >>    it is not belong to OS API level for outside (at least, for c=
urrent case, it is true).=20
>>> >>    so we need not keep 'compatible' of it, so %16s is not necess=
ary.
>> >=20
>> > Can you explain If we don't change to %s, what will happen?
>> >=20
>   for outside, nothing will happen.
>=20
>   so it is not for correctness, it is only for "keep source code simp=
le and clear".
>=20
>>> >>
>>> >>  for keeping source code simple and clearly:
>>> >>    %s is better than %16s.
>>> >>
>>> >>  so for result, we should choose %s only (neither %16s nor %8s).
>> >=20
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >=20
>> >=20
>=20
> -- Chen Gang Asianux Corporation -- To unsubscribe from this list: se=
nd
> the line "unsubscribe netdev" in the body of a message to
> majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
>=20


--=20
Chen Gang

Asianux Corporation
