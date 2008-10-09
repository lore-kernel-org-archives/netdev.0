From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tcpv[46]: fix md5 pseudoheader address field
 ordering
Date: Thu, 09 Oct 2008 14:37:55 -0700 (PDT)
Message-ID: <20081009.143755.201233180.davem@davemloft.net>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755426AbYJIViT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 17:38:19 -0400
In-Reply-To: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu,  9 Oct 2008 12:35:34 +0300

> Maybe it's just me but I guess those md5 people made a mess
> out of it by having *_md5_hash_* to use daddr, saddr order
> instead of the one that is natural (and equal to what csum
> functions use). For the segment were sending, the original
> addresses are reversed so buff's saddr =3D=3D skb's daddr and
> vice-versa.
>=20
> Maybe I can finally proceed with unification of some code
> after fixing it first... :-)
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
