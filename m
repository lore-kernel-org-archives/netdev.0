From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix possible NULL dereference in
 tcp_vX_send_reset()
Date: Wed, 26 Nov 2014 12:09:51 -0500 (EST)
Message-ID: <20141126.120951.631006073056672211.davem@davemloft.net>
References: <1416930004.29427.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dborkman@redhat.com, jasa.bartelj@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaKZRJx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:09:53 -0500
In-Reply-To: <1416930004.29427.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Nov 2014 07:40:04 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> After commit ca777eff51f7 ("tcp: remove dst refcount false sharing fo=
r
> prequeue mode") we have to relax check against skb dst in
> tcp_v[46]_send_reset() if prequeue dropped the dst.
>=20
> If a socket is provided, a full lookup was done to find this socket,
> so the dst test can be skipped.
>=20
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D88191
> Reported-by: Ja=A8a Bartelj <jasa.bartelj@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Daniel Borkmann <dborkman@redhat.com>
> Fixes: ca777eff51f7 ("tcp: remove dst refcount false sharing for preq=
ueue mode")

Applied, thanks Eric.
