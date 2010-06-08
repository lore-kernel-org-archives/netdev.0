From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: avoid two atomic ops in
 ip_rt_redirect()
Date: Tue, 08 Jun 2010 06:56:48 +0200
Message-ID: <1275973008.2775.49.camel@edumazet-laptop>
References: <1275916983.2545.73.camel@edumazet-laptop>
	 <20100607.212622.267982352.davem@davemloft.net>
	 <20100607.215119.176661892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:40821 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab0FHE4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:56:52 -0400
Received: by wwb28 with SMTP id 28so194395wwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 21:56:51 -0700 (PDT)
In-Reply-To: <20100607.215119.176661892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 21:51 -0700, David Miller a =C3=A9crit :
> From: David Miller <davem@davemloft.net>
> Date: Mon, 07 Jun 2010 21:26:22 -0700 (PDT)
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 07 Jun 2010 15:23:03 +0200
> >=20
> >> in_dev_get() -> __in_dev_get_rcu() in a rcu protected function.
> >>=20
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied.
>=20
> I needed to modify this patch to get it to build.
>=20
> You left a code label with no code afterwards at the end of
> ip_rt_redirect() when CONFIG_IP_ROUTE_VERBOSE is disabled,
> which breaks the build.
>=20
> I fixed it by adding a semicolon.

OK, thanks David, I missed this.



