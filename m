From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 29 Jun 2007 10:50:20 +0200
Message-ID: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update...
I did 2 tests :

1)  booted with option acpi=3Doff
It booted correctly, i managed to get some load on one of the card and =
after a while (10 minutes i guess) the Timeout occurs. Side effect, at =
the same moment the sata contolers lost control of the disks somehow an=
d the raid 5 array on the system crashed hard. I have no traces as i wa=
s unable to rebuild it (and i tried a lot of extreme  voodoo methods).

2) changed the 3com cards
i replaced by two cards,
01:06.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (=
rev 42)
01:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029(A=
S)

reinstalled and stressed the network (small download from a laptop) and=
 :

Jun 29 09:34:10 loki kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 29 09:34:51 loki last message repeated 14 times
Jun 29 09:35:18 loki last message repeated 8 times

so it seems to be a more generic problem.

(i'v updated the fedora bugzilla aswell)

did not test the  "[PATCH] 8139cp dev->tx_timeout" yet.

JB


> On Tue, Jun 26, 2007 at 04:24:07PM +0200, Jean-Baptiste Vignaud wrote=
:
> > Hello, i have a very similar problem with 2.6.21 also;
> >=20
> > 2 3com NICs and they are failling randomly.
> >=20
> > The kernel is a basic fedora 7 kernel (2.6.21-1.3228.fc7)
> > I found a bug report and added details here : https://bugzilla.redh=
at.com/bugzilla/show_bug.cgi?id=3D243960
> >=20
> > I'm not subcribed on this list, so please cc me if there is any que=
stions.
> >=20
> > JB
> >=20
> > > On Tue, Jun 26, 2007 at 08:10:17AM +0200, Marcin =C5=9Alusarz wro=
te:
> > > ...
> > > > I reproduced it on minimal config:
> ...
> > > We know your hardware should be OK - since it was fine with 2.6.2=
0.
> ...
>=20
> It looks like there is something common in the air...
>=20
> Marcin: ne2k_pci with 8390, Jean: 3com, and now I see
> similar problem with 8139cp too (plus some ideas):
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D118293314109648&w=3D2
>=20
> So, you probably should wait a little & look for new patches here.
>=20
> Cheers,
> Jarek P.
>=20

