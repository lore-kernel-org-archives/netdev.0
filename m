From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: Fix wrong order of ip_rt_get_source() and update
 iph->daddr.
Date: Fri, 10 Feb 2012 15:08:10 +0800
Message-ID: <4F34C25A.4020904@cn.fujitsu.com>
References: <4F34BDAD.8080608@cn.fujitsu.com> <1328857450.2436.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52340 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754340Ab2BJHIH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:08:07 -0500
In-Reply-To: <1328857450.2436.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet =E5=86=99=E9=81=93:
> Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 14:48 +0800, Li Wei a =C3=A9c=
rit :
>> Need to update iph->daddr before ip_rt_get_source(), otherwise
>> we may get a wrong src.
>>
>=20
> It would be nice that patch submitters try to pinpoint bug origin in
> changelog, to ease patch review and stable submissions.
>=20
> Is it coming from ac8a48106be49c422575ddc7531b776f8eb49610 (ipv4: Sav=
e
> nexthop address of LSRR/SSRR option to IPCB.) added in 3.2, or is it
> something needing a backport in some other way in old kernels ?

As you said, it is coming from ac8a48106be49c422575ddc7531b776f8eb49610=
=20
(ipv4: Save nexthop address of LSRR/SSRR option to IPCB.).

I'll modify the changelog and post a v2.

Thanks!

>=20
> Thanks !
>=20
>=20
>=20
>=20
