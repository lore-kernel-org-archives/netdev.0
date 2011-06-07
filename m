From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Tue, 07 Jun 2011 05:19:25 +0200
Message-ID: <1307416765.2642.37.camel@edumazet-laptop>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
	 <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36112 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab1FGDT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 23:19:29 -0400
Received: by wya21 with SMTP id 21so3245127wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 20:19:28 -0700 (PDT)
In-Reply-To: <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 juin 2011 =C3=A0 04:39 +0300, Lucian Adrian Grijincu a =C3=A9=
crit :
> The most like case is that no one else is registering devices with a
> name like "dummy%d".
>=20
> We can bring the complexity down by replacing:
> - alloc_netdev_id which is O(N) with
> - alloc_netdev_id which, on the average case, is O(1).
>=20
> $ time modprobe dummy numdummies=3D5000
> - with alloc_netdev   : 9.50s
> - with alloc_netdev_id: 3.50s
>=20
> NOTE: Stats generated on a heavily patched 3.0-rc1 which replaces the
>       current O(N^2) sysctl algorithm with a better one.

Yes, and disabled hotplug I guess.

Dont try this on a random computer ;)

# time modprobe dummy numdummies=3D5000

real	4m45.646s
user	0m0.000s
sys	0m12.440s
# uptime
 05:13:46 up 13:30,  3 users,  load average: 11221.41, 6918.70, 3101.12
# uptime
 05:18:45 up 13:35,  3 users,  load average: 12159.82, 10277.39, 5623.1=
9



