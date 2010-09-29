From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 09:45:52 +0200
Message-ID: <1285746352.2615.11.camel@edumazet-laptop>
References: <20100928.214132.226782961.davem@davemloft.net>
	 <20100928.223850.104051485.davem@davemloft.net>
	 <1285742848.22570.53.camel@edumazet-laptop>
	 <20100929.002544.183044247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55794 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab0I2Hp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:45:57 -0400
Received: by fxm14 with SMTP id 14so282154fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 00:45:56 -0700 (PDT)
In-Reply-To: <20100929.002544.183044247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 00:25 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 29 Sep 2010 08:47:28 +0200
>=20
> > Still, this does not solve the problem for people wanting to disabl=
e
> > ipv6 module load or disable it ?
> >=20
> > install ipv6 /bin/true
> >=20
> > or
> >=20
> > options ipv6 disable=3D1
>=20
> If you set the disable option, it should do the right thing.  Since
> the ipv6 symbols will be available, yet the ipv6 stack won't by
> default bring up ipv6 addresses onto interfaces etc.

I must miss something obvious.

David, with your patch, I cant :

install ipv6 /bin/true
modprobe ip_gre

=46ATAL: Error inserting ip_gre
(/lib/modules/2.6.36-rc6-dirty/kernel/net/ipv4/ip_gre.ko): Unknown
symbol in module, or unknown parameter (see dmesg)

[  223.150774] ip_gre: Unknown symbol icmpv6_send (err 0)

Thanks


