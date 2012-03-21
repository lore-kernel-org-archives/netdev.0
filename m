From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V1 6/6] IB/rdma_cm: TOS <=> UP mapping for IBoE
Date: Wed, 21 Mar 2012 03:03:16 -0700
Message-ID: <1332324196.25742.8.camel@edumazet-laptop>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
	 <1332321903-11704-7-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Sean Hefty <sean.hefty@intel.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50135 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030253Ab2CUKDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 06:03:24 -0400
Received: by pbcun15 with SMTP id un15so693467pbc.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 03:03:24 -0700 (PDT)
In-Reply-To: <1332321903-11704-7-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 mars 2012 =C3=A0 11:25 +0200, Amir Vadai a =C3=A9crit :
> From: Amir Vadai <amirv@mellanox.co.il>
>=20
> Both tagged traffic and untagged traffic use tc tool mapping.
> Treat RDMA TOS same as IP TOS when mapping to SL
>=20
> Since IP TOS to priority mapping is not exported, had to borrow the c=
ode from
> net/ipv4/route.c
>=20
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> CC: Sean Hefty <sean.hefty@intel.com>
>=20
> ---
>=20
> We can export IP TOS to priority mapping if the networking maintainer=
s will say
> where they want it.

Yes please do so. This makes no sense to duplicate ip_tos2prio[]
