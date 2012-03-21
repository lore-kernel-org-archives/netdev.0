From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V1 4/6] net/mlx4_en: Set max rate-limit for a TC
Date: Wed, 21 Mar 2012 03:12:56 -0700
Message-ID: <1332324776.25742.14.camel@edumazet-laptop>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
	 <1332321903-11704-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48764 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030708Ab2CUKNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 06:13:04 -0400
Received: by pbcun15 with SMTP id un15so698532pbc.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 03:13:03 -0700 (PDT)
In-Reply-To: <1332321903-11704-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 mars 2012 =C3=A0 11:25 +0200, Amir Vadai a =C3=A9crit :
> From: Amir Vadai <amirv@mellanox.co.il>
>=20
> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ra=
telimit
>=20
> To set, enter a space separated list of values in units of 100Mbps.  =
=46or
> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 i=
ssue:
> echo 50 100 100 100 100 100 100 100 100 > /sys/class/net/eth2/qos/rat=
elimit
>=20

Oh thats not very user friendly.

I suggest one value per file (Its probably a generic /sys rule anyway)
and not using 100Mps for the unit, even if it is the base granularity o=
f
this hardware.


/sys/class/net/eth2/qos/0/ratelimit
=2E..
/sys/class/net/eth2/qos/7/ratelimit
