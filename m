From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB class parameter change
Date: Thu, 28 May 2009 22:54:51 +0200
Message-ID: <4A1EFA1B.2020002@gmail.com>
References: <620d582f0905281347w5aa96a85na5339aed87db5464@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Piotrek D <regis44@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46579 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764220AbZE1Uy4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 16:54:56 -0400
In-Reply-To: <620d582f0905281347w5aa96a85na5339aed87db5464@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Piotrek D a =E9crit :
> HI,
>=20
> I am trying to change the rate parameter of HTB class by using this
> code from within one of my functions :
>=20
>  struct htb_class *cl;
>  cl=3Dhtb_find(number,q);
>=20
>  cl->rate->rate.rate =3D NEW_RATE_VALUE;
>=20
>  TC shows the correct values, but the traffic rate doesn't change a b=
it.
>  Does anyboyd have any idea what am I doing wrong ? Maybe there would
> be a faster way by sending a netlink  message ?
>=20
> Piotrek


You already asked this 15 hours ago and Stephen replied :

"HTB uses a rate table, so if you want the rate to change, you will nee=
d to change the
table as well."

Did you miss this answer ?

