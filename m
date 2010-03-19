From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Fri, 19 Mar 2010 06:28:11 +0100
Message-ID: <1268976491.2894.221.camel@edumazet-laptop>
References: <1268955460.2894.207.camel@edumazet-laptop>
	 <20100318.222226.191403090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36452 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab0CSF2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:28:16 -0400
Received: by bwz1 with SMTP id 1so2680531bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:28:14 -0700 (PDT)
In-Reply-To: <20100318.222226.191403090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 mars 2010 =C3=A0 22:22 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Mar 2010 00:37:40 +0100
>=20
> > We currently force a synchronize_net() in netdev_set_master()
> >=20
> > This seems necessary only when a slave had a master and we dismantl=
e it.
> >=20
> > In the other case ("ifenslave bond0 ethO"), we dont need this long
> > delay.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Depends upon the net-2.6 race fix?
>=20
> Thanks for telling me :-/

I believe it's not related. It's net-next-2.6 material, for sure :)

But yes, I discovered the race fix while studying netdev_set_master()

Thanks David


