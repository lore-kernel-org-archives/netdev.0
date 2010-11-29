From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 19:46:03 +0100
Message-ID: <1291056363.3435.1338.camel@edumazet-laptop>
References: <4CF3DD02.90906@oracle.com>
	 <1291051560.3435.1198.camel@edumazet-laptop>  <4CF3F114.2070108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: John Haxby <john.haxby@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64222 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0K2SqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 13:46:08 -0500
Received: by wwa36 with SMTP id 36so5050235wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 10:46:06 -0800 (PST)
In-Reply-To: <4CF3F114.2070108@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 18:29 +0000, John Haxby a =C3=A9crit :

> Sorry,  I think I phrased my question badly.
>=20
> inet_csk_get_port() starts its search for a free port with
>=20
>      smallest_rover =3D rover =3D net_random() % remaining + low;
>=20
> whereas __inet_hash_connect() basically misses out that call to=20
> net_random() so you get a predictable port number.
>=20
> Is there any good reason why that is the case?
>=20

It seems random select was done at bind() time only in commit
6df716340da3a6f ([TCP/DCCP]: Randomize port selection)

It probably should be done in autobind too.



