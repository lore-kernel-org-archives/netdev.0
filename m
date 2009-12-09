From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Handle NETREG_UNINITIALIZED devices correctly
Date: Wed, 09 Dec 2009 10:57:44 +0100
Message-ID: <4B1F7498.2090007@gmail.com>
References: <20091209082602.19053.97297.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35984 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557AbZLIJ5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 04:57:51 -0500
In-Reply-To: <20091209082602.19053.97297.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Fix two problems:
>=20
> 1. If unregister_netdevice_many() is called with both registered
>    and unregistered devices, rollback_registered_many() bails out
>    when it reaches the first unregistered device. The processing
>    of the prior registered devices is unfinished, and the
>    remaining devices are skipped, and possible registered netdev's
>    are leaked/unregistered.
>=20
> 2. System hangs or panics depending on how the devices are passed,
>    since when netdev_run_todo() runs, some devices were not fully
>    processed.
>=20
> Tested by passing intermingled unregistered and registered vlan
> devices to unregister_netdevice_many() as follows:
> 	1. dev, fake_dev1, fake_dev2: hangs in run_todo
> 	   ("unregister_netdevice: waiting for eth1.100 to become
> 	    free. Usage count =3D 1")
> 	2. fake_dev1, dev, fake_dev2: failure during de-registration
> 	   and next registration, followed by a vlan driver Oops
> 	   during subsequent registration.
>=20
> Confirmed that the patch fixes both cases.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
