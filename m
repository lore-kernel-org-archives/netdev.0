From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: use gre key as flow upper protocol info
Date: Sun, 28 Nov 2010 11:22:41 -0800 (PST)
Message-ID: <20101128.112241.232741941.davem@davemloft.net>
References: <1288795298-323-1-git-send-email-timo.teras@iki.fi>
	<20101115.104322.212675424.davem@davemloft.net>
	<4CEBC9C1.8080101@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791Ab0K1TWP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 14:22:15 -0500
In-Reply-To: <4CEBC9C1.8080101@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 23 Nov 2010 16:03:45 +0200

> So we probably would need to do:
>=20
> xfrm: fix gre key endianess
>=20
> fl->fl_gre_key is network byte order contrary to fl->fl_icmp_*.
> Make xfrm_flowi_{s|d}port return network byte order values for gre
> key too.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Ok, applied, thanks Timo.
