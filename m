From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NETLINK : kzalloc() conversion
Date: Tue, 11 Dec 2007 06:46:54 +0100
Message-ID: <475E244E.5040301@cosmosbay.com>
References: <475E22C2.9050700@cosmosbay.com> <20071210.214337.86437493.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35723 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbXLKFrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 00:47:09 -0500
In-Reply-To: <20071210.214337.86437493.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <475E22C2.9050700@cosmosbay.com> (at Tue, 11 Dec 2007 06:4=
0:18 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>=20
>> nl_pid_hash_alloc() is renamed to nl_pid_hash_zalloc().
>> It is now returning zeroed memory to its callers.
>=20
> I do think you do not need (and you should not) rename it
> because XXX_zalloc() would imply we have raw XXX_alloc().
>=20

Well, its a static function, so a single grep should satisfy
reader's concern :)


