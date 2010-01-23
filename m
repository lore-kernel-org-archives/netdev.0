From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Sat, 23 Jan 2010 02:20:55 -0800 (PST)
Message-ID: <20100123.022055.258206634.davem@davemloft.net>
References: <b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
	<20100110.131524.241344047.davem@davemloft.net>
	<55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lorenzo@google.com, therbert@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39778
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754748Ab0AWKUn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2010 05:20:43 -0500
In-Reply-To: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Wed, 13 Jan 2010 16:51:30 -0800

> I believe you are looking for the following patch.
>=20
> I don't think it solves the problem of source based routing to any
> (significantly) greater extent than the previous patch.
> That would actually require iterating over all IPs assigned to any
> interface on our machine.
>=20
> However, I really don't understand the code (nor the precise issues
> involved) sufficiently well to be certain of that.
>=20
> I actually think the ipv4 code path suffers from a very similar probl=
em.
>=20
> Mind you - I don't think these issues are really significant problems=
,
> because they just mean we do PMTU once per (dest ip, src ip) instead
> of once per (dest ip).

Yes, this is about right.

Please resubmit with a proper Signed-off-by: tag so I can apply
this, thanks.
