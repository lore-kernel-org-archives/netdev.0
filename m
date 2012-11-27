From: Chen Gang <gang.chen@asianux.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Tue, 27 Nov 2012 13:35:59 +0800
Message-ID: <50B4513F.8090804@asianux.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com> <50B447F3.2090806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:36690 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab2K0FfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 00:35:05 -0500
In-Reply-To: <50B447F3.2090806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA11=D4=C227=C8=D5 12:56, Shan Wei =D0=B4=B5=C0:
> Chen Gang said, at 2012/11/27 12:18:
>>>
>>>>
>>>>  for the format of information which seq_printf output:
>>>>    it is not belong to OS API level for outside (at least, for cur=
rent case, it is true).=20
>>>>    so we need not keep 'compatible' of it, so %16s is not necessar=
y.
>>>
>>> Can you explain If we don't change to %s, what will happen?
>>>
>>
>>   for outside, nothing will happen.
>>
>>   so it is not for correctness, it is only for "keep source code sim=
ple and clear".
>=20
> So, it's a clean-up type patch which is just for developer,
> but with the change of /proc interface which is for user.
> user is first, so let us end this thread unless you have necessary re=
asons to do it.=20
>=20

1)  it is not change the /proc interface.
    a) both %8s and %s do not change the output interface format (inclu=
ding contents, topology, separator mark, space redundancy).
    b) it is belong to 'User Experience', not belong to os api.
    c) do you agree with what I say above ?

2)  I think:
    one of the differences between system service and user interactive =
program are:
      for system service (including kernel): "clean-up" is more importa=
nt than "UE".
      for user interactive program:          "UE" is more important tha=
n "Clean-up".
    maybe, it is for ideal world (or maybe it is only in theory).
    (also maybe what I said above is incorrect)


3)  so all together:
    I can understand if it is not integrated into main branch.
    it will be better to continue discussing it in ideal world (or in t=
heory), I think it is valuable for learning with each other.

  :-)

  thanks.

gchen.

> Thanks =20
> Shan Wei
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
