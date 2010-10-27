From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tunnels: Fix tunnels change rcu protection
Date: Wed, 27 Oct 2010 21:06:12 +0200
Message-ID: <1288206372.2658.13.camel@edumazet-laptop>
References: <4CC848B9.1060406@parallels.com>
	 <1288206172.2658.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36847 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab0J0TGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:06:17 -0400
Received: by wwe15 with SMTP id 15so1145433wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 12:06:16 -0700 (PDT)
In-Reply-To: <1288206172.2658.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 21:02 +0200, Eric Dumazet a =C3=A9cr=
it :


> Hmm, maybe we should allocate a "struct ip_tunnel_parm" instead of us=
ing
> an embedded one (in struct ip_tunnel), and stick an rcu_head in it to
> delay its freeing...
>=20

I forgot to Ack your patch, of course.

We can implement something better when net-next-2.6 re-opens.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



