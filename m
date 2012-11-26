From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Mon, 26 Nov 2012 10:30:02 +0800
Message-ID: <50B2D42A.6090804@asianux.com>
References: <50AC9CF6.2020501@asianux.com>  <1353872669.30446.863.camel@edumazet-glaptop>  <50B2C470.5090802@asianux.com>  <50B2C72F.9000100@asianux.com> <1353896372.30446.866.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:8490 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab2KZC3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 21:29:08 -0500
In-Reply-To: <1353896372.30446.866.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8826=E6=97=A5 10:19, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Mon, 2012-11-26 at 09:34 +0800, Chen Gang wrote:
>=20
>>     if "pimre%u" (or another format), will not hurt the functional f=
eatures, I suggest to use it
>>       since, we need try our best to not touch the OS API.=20
>>       ("pimreg%u" seems an internal format, not OS API Level)
>=20
> Have you taken a look at user code base before suggesting such a
> change ?

  maybe a hacker can do ?  (I just guess).

  for my experience:
    It is necessary to think of more coding ways, when we have to give =
comments inside a function.


>=20
> My patch is the safest change: Just make sure machine doesnt crash if
> user ask stupid things.
>=20
> No possible regression.
>=20
>=20
>=20
>=20
>=20


--=20
Chen Gang

Asianux Corporation
