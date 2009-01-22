From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Wed, 21 Jan 2009 22:21:12 -0800 (PST)
Message-ID: <20090121.222112.245293949.davem@davemloft.net>
References: <49780AA9.9050508@iki.fi>
	<20090121.220304.211246256.davem@davemloft.net>
	<49780EB5.60300@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755171AbZAVGVK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 01:21:10 -0500
In-Reply-To: <49780EB5.60300@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 22 Jan 2009 08:14:13 +0200

> David Miller wrote:
> > From: Timo Ter=E4s <timo.teras@iki.fi>
> > Date: Thu, 22 Jan 2009 07:56:57 +0200
> >=20
> >> Is there any particular reason why setting NAT-OA info should/
> >> must be done using netlink? Or is this just a way to try to
> >> put more pressure for the change to happen?
> >=20
> > Because it isn't deprecated if we keep adding features to it.
>=20
> I would not consider this a new feature. It just makes pfkey
> act consistently. If you don't want it supported, it'd make
> more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
> the verification code already present than to silently
> ignore it. Make kernel return an error if some tried using it.

=46air enough, sounds like a reasonable argument.

Herbert what do you think?  The proposal is that we just reflect the
value we get, rather than acting upon it.
