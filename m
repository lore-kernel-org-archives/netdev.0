From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Tue, 05 Oct 2010 09:31:55 +0200
Message-ID: <1286263915.2796.13.camel@edumazet-laptop>
References: <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101005.002450.58425682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52589 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab0JEHcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:32:02 -0400
Received: by fxm4 with SMTP id 4so207914fxm.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 00:31:58 -0700 (PDT)
In-Reply-To: <20101005.002450.58425682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 00:24 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 02 Oct 2010 18:11:55 +0200
>=20
> > [PATCH net-next V3] net: dynamic ingress_queue allocation
> >=20
> > ingress being not used very much, and net_device->ingress_queue bei=
ng
> > quite a big object (128 or 256 bytes), use a dynamic allocation if
> > needed (tc qdisc add dev eth0 ingress ...)
> >=20
> > dev_ingress_queue(dev) helper should be used only with RTNL taken.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This looks good to me, applied, thanks Eric.

Thanks to Jarek, Jamal, and you :)


