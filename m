From: Lukasz Trabinski <lukasz@trabinski.net>
Subject: Re: unregister_netdevice 2.6.9
Date: Tue, 19 Oct 2004 20:53:09 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58LT.0410191953390.13480@lt.wsisiz.edu.pl>
References: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
 <20041020.022622.27982693.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041020.022622.27982693.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004, YOSHIFUJI Hideaki / ???? wrote:

> > whreis xxxx is name of sit device, created via script
>=20
> Is your box acting as router, or host?
> % sysctl -a |grep ipv6|grep forwarding

lt:~# sysctl -a |grep ipv6|grep forwarding
net.ipv6.conf.atman6.forwarding =3D 0
net.ipv6.conf.eth1.forwarding =3D 0
net.ipv6.conf.eth0.forwarding =3D 0
net.ipv6.conf.lo.forwarding =3D 0
net.ipv6.conf.default.forwarding =3D 0
net.ipv6.conf.all.forwarding =3D 0

atman6 is sit device, ipv6 is loaded as module.


> What is happend if you let the interface down and delete it before
> becore rebooting?

OK, if interface is down, system is rebooting correctly.

I had made tests with shutdown interfaces, but i shutdowned wrong sit=20
interface. :( Sorry for that.=20

Anyway, ipip interfaces no need to be shutdown before reboot. Is it
problem in sit_cleanup()?


--=20
=A3T
