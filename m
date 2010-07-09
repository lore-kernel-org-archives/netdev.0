From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug handling devices with weird names
Date: Fri, 09 Jul 2010 12:19:39 +0200
Message-ID: <1278670779.2696.1.camel@edumazet-laptop>
References: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
	 <20100708102747.66d0ad78@s6510>
	 <AANLkTim3IpnHn8ZedpYAphlA1ZdhzizuJo-azmPtd-kd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61849 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817Ab0GIKTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 06:19:45 -0400
Received: by wwb24 with SMTP id 24so4686803wwb.1
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 03:19:43 -0700 (PDT)
In-Reply-To: <AANLkTim3IpnHn8ZedpYAphlA1ZdhzizuJo-azmPtd-kd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 juillet 2010 =C3=A0 12:04 +0200, Mart=C3=ADn Ferrari a =C3=
=A9crit :
> On Thu, Jul 8, 2010 at 19:27, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> > Colons are used for the old IP aliasing. IP aliasing was an older w=
ay of handling
> > multiple addresses per interface, and is not necessary anymore. The=
 syntax is
> > retained for legacy compatibility.
>=20
> I know, but there is some code that is not accepting any valid name.
> So i am able to create the device but then I cannot do some stuff. So
> that's why I think this is a bug.
>=20
>=20

Update user land tools ?

No problem here :

# ip link add name foo: type dummy
# ip link list foo:
14: foo:: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN=20
    link/ether e6:48:a9:57:d4:1f brd ff:ff:ff:ff:ff:ff
# ip link del foo:
# ip -V
ip utility, iproute2-ss100519


