From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v4] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 18:44:48 +0800
Message-ID: <51790920.1030401@asianux.com>
References: <5175DFBC.7040000@asianux.com> <5175F7F7.7000703@asianux.com> <51766F74.2090007@asianux.com> <20130425.041044.768895561908042668.davem@davemloft.net> <5178ECA2.6020402@asianux.com> <5178F120.5030500@acn-group.ch> <5178FA0D.8060009@asianux.com> <5178FE6A.3050108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>,
	sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:45896 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757738Ab3DYKpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:45:36 -0400
In-Reply-To: <5178FE6A.3050108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8825=E6=97=A5 17:59, Daniel Borkmann wrote:
> Change MAC802154_CHAN_NONE from ~(u8)0 to 0xff, otherwise the compari=
son
> in mac802154_wpan_xmit() for ``chan =3D=3D MAC802154_CHAN_NONE'' will=
 not
> succeed.
> This bug can be boiled down to ``u8 foo =3D 0xff; if (foo =3D=3D ~(u8=
)0) [...]
> else [...]'' where the condition will always take the else branch.
>=20
> ... something like that maybe?

That sounds good !!

I prefer to send patch v5 for that.

:-)

--=20
Chen Gang

Asianux Corporation
