From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 net-next] neigh: new unresolved queue limits
Date: Wed, 09 Nov 2011 12:10:29 +0100
Message-ID: <1320837029.2315.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320792301.26025.21.camel@edumazet-laptop>
	 <20111108.174820.558780148839093199.davem@davemloft.net>
	 <1320797656.26025.43.camel@edumazet-laptop>
	 <20111109.001843.1753987502002673227.davem@davemloft.net>
	 <1320825325.26025.51.camel@edumazet-laptop>
	 <1320836664.2315.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42594 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab1KILKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 06:10:33 -0500
Received: by bke11 with SMTP id 11so1227504bke.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 03:10:32 -0800 (PST)
In-Reply-To: <1320836664.2315.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 12:04 +0100, Eric Dumazet a =C3=A9c=
rit :
> unres_qlen is the number of frames we are able to queue per unresolve=
d
> neighbour. Its default value (3) was never changed and is responsible
> for strange drops, especially if IP fragments are used, or multiple
> sessions start in parallel. Even a single tcp flow can hit this limit=
=2E
>=20

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Oh well I forgot the missing bit :

 [NDTPA_QUEUE_LENBYTES]          =3D { .type =3D NLA_U32 },

I am sending a V4 ASAP
