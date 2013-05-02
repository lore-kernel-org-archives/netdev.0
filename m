From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v5] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 02 May 2013 09:11:38 +0800
Message-ID: <5181BD4A.90408@asianux.com>
References: <5178FA0D.8060009@asianux.com> <5178FE6A.3050108@redhat.com> <51790A53.8040107@asianux.com> <20130429.122934.2073602835665028801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dborkman@redhat.com, c.aeschlimann@acn-group.ch,
	sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:2134 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab3EBBM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 21:12:26 -0400
In-Reply-To: <20130429.122934.2073602835665028801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8830=E6=97=A5 00:29, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Thu, 25 Apr 2013 18:49:55 +0800
>=20
>>
>> Change MAC802154_CHAN_NONE from ~(u8)0 to 0xff, or the comparison in
>> mac802154_wpan_xmit() for ``chan =3D=3D MAC802154_CHAN_NONE'' will n=
ot
>> succeed.
>>
>> This bug can be boiled down to ``u8 foo =3D 0xff; if (foo =3D=3D ~(u=
8)0)
>> [...] else [...]'' where the condition will always take the else
>> branch.=20
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>=20
> Applied, thanks.
>=20
>=20

Thank you, too, and also thank the related members who provide your
suggestions to this patch.

--=20
Chen Gang

Asianux Corporation
