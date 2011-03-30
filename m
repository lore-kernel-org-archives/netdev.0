From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: mcast snooping, fix length check of snooped
 MLDv1/2
Date: Wed, 30 Mar 2011 02:30:01 -0700 (PDT)
Message-ID: <20110330.023001.13743450.davem@davemloft.net>
References: <20110327034404.GC31916@Sellars>
	<1301207244-10428-1-git-send-email-linus.luessing@web.de>
	<1301207244-10428-3-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: linus.luessing@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753566Ab1C3Jao convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 05:30:44 -0400
In-Reply-To: <1301207244-10428-3-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=FCssing <linus.luessing@web.de>
Date: Sun, 27 Mar 2011 08:27:24 +0200

> "len =3D ntohs(ip6h->payload_len)" does not include the length of the=
 ipv6
> header itself, which the rest of this function assumes, though.
>=20
> This leads to a length check less restrictive as it should be in the
> following line for one thing. For another, it very likely leads to an
> integer underrun when substracting the offset and therefore to a very
> high new value of 'len' due to its unsignedness. This will ultimately
> lead to the pskb_trim_rcsum() practically never being called, even in
> the cases where it should.
>=20
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Applied.
