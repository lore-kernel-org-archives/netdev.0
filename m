From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sparse noise due to patch "net: fix kmemcheck annotations"
Date: Wed, 11 Nov 2009 22:13:02 +0100
Message-ID: <4AFB28DE.8070000@gmail.com>
References: <4AFB217E.2040209@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51743 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759225AbZKKVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:13:07 -0500
In-Reply-To: <4AFB217E.2040209@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter a =E9crit :
> Hi Eric,
>=20
> with above mentioned patch, committed as
> 14d18a81b5171d4433e41129619c75748b4f4d26, you changed
>=20
> struct sk_buff {
> 	...
> 	__be16 protocol;
> 	...
> }
> to
> 	__be16 protocol:16;
>=20
> This introduces the following warning from sparse:
>=20
> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
> type restricted __be16.
>=20
> So, one checker satisfied, another disturbed?  Any idea how to get th=
is
> sparse-clean again?

No problem here... how do you get this error, and what is your sparse v=
ersion ?
