From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] macvlan: use call_rcu for port free
Date: Mon, 07 Jun 2010 14:15:36 +0200
Message-ID: <1275912936.2545.48.camel@edumazet-laptop>
References: <20100607113629.GA2730@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52937 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458Ab0FGMPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 08:15:41 -0400
Received: by fxm8 with SMTP id 8so2005399fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 05:15:39 -0700 (PDT)
In-Reply-To: <20100607113629.GA2730@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 13:36 +0200, Jiri Pirko a =C3=A9crit :
> Use call_rcu rather than synchronize_rcu.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/macvlan.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


