From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: fix rcu splat in neigh_update()
Date: Tue, 18 Oct 2011 11:11:35 +0200
Message-ID: <1318929095.2657.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318926762-14563-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ari.m.savolainen@gmail.com, netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60337 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab1JRJLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 05:11:17 -0400
Received: by eye27 with SMTP id 27so334440eye.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 02:11:16 -0700 (PDT)
In-Reply-To: <1318926762-14563-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 16:32 +0800, roy.qing.li@gmail.com a =C3=
=A9crit :
> when use dst_get_neighbour to get neighbour, we need=20
> rcu_read_lock to protect, since dst_get_neighbour uses
> rcu_dereference.
>=20
> The bug was reported by Ari Savolainen <ari.m.savolainen@gmail.com>
>=20
=2E..
>=20
> Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
> Signed-off-by: RongQing <roy.qing.li@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
