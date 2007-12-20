From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/3] Uninline the __inet_hash function
Date: Thu, 20 Dec 2007 00:30:27 -0800 (PST)
Message-ID: <20071220.003027.20529103.davem@davemloft.net>
References: <47694231.2070406@cosmosbay.com>
	<47694F96.6030604@openvz.org>
	<476951A8.4040200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbXLTIac convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 03:30:32 -0500
In-Reply-To: <476951A8.4040200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 19 Dec 2007 18:15:20 +0100

> Pavel Emelyanov a =E9crit :
> > That's not truth, if I get you right. The __inet_hash() is called
> > with 0, from all the places except for the inet_hash() one.
>=20
> OK, but on cases with 0, sk->sk_state is !=3D TCP_LISTEN, unless I am=
 mistaken.

This is true.
