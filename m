From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: network speed extremly slowed down
Date: Mon, 14 Mar 2005 18:51:36 +0100
Message-ID: <200503141851.38468.bernd.schubert@pci.uni-heidelberg.de>
References: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de> <20050314092153.79ae93f1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050314092153.79ae93f1@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 14 March 2005 18:21, Stephen Hemminger wrote:
> On Mon, 14 Mar 2005 17:45:06 +0100
>
> Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de> wrote:
> > Hi,
> >
> > until one hour ago I thought this bug affects only 3com 3c509B cards.=
 Now
> > we go on switching more and more systems from 2.4.X to 2.6.X and it s=
eems
> > that many cards work much slower with 2.6.X
> >
> > with 2.4.27:
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D
> > bernd@pc-brenn bernd>nttcp -T hamilton2
> >      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s =
=20
> > CPU-C/s l  8388608    0.72    0.02     92.7710   3355.4432    2048 =20
> > 2831.15  102400.0 1  8388608    0.73    0.04     92.0581   1864.3941 =
 =20
> > 5783   7932.96  160661.2
> >
> > with 2.6.11.3:
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > bernd@pc-brenn bernd>nttcp -T hamilton2
> >      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s =
=20
> > CPU-C/s l  8388608    3.29    3.28     20.3957     20.4569    2048  =20
> > 622.43     624.3 1  8388608    3.29    0.04     20.3923   1637.0411  =
=20
> > 6143   1866.67  149851.2
>
> What type is the other host (hamilton2) and what is the round trip dela=
y?
> Is it on the same local network?

Yes of course, hamilton2 is on our local network. And of course, this is=20
completely independet of hamilton2, it can be reproduced with any local=20
system (as long as this system has full network speed, of course ;) ).


Round trip delay, e.g. the ping time?

Hmm, interesting!


2.4.27:
=3D=3D=3D=3D=3D
bernd@wigner bernd>ping hamilton2
PING hamilton2.pci.uni-heidelberg.de (129.206.21.202): 56 data bytes
64 bytes from 129.206.21.202: icmp_seq=3D0 ttl=3D64 time=3D0.1 ms
64 bytes from 129.206.21.202: icmp_seq=3D1 ttl=3D64 time=3D0.1 ms
64 bytes from 129.206.21.202: icmp_seq=3D2 ttl=3D64 time=3D0.1 ms
64 bytes from 129.206.21.202: icmp_seq=3D3 ttl=3D64 time=3D0.1 ms
64 bytes from 129.206.21.202: icmp_seq=3D4 ttl=3D64 time=3D0.1 ms
64 bytes from 129.206.21.202: icmp_seq=3D5 ttl=3D64 time=3D0.1 ms


2.6.11.3
=3D=3D=3D=3D=3D=3D
bernd@wigner bernd>ping hamilton2
PING hamilton2.pci.uni-heidelberg.de (129.206.21.202): 56 data bytes
64 bytes from 129.206.21.202: icmp_seq=3D0 ttl=3D64 time=3D0.9 ms
64 bytes from 129.206.21.202: icmp_seq=3D1 ttl=3D64 time=3D0.4 ms
64 bytes from 129.206.21.202: icmp_seq=3D2 ttl=3D64 time=3D0.5 ms
64 bytes from 129.206.21.202: icmp_seq=3D3 ttl=3D64 time=3D0.4 ms
64 bytes from 129.206.21.202: icmp_seq=3D4 ttl=3D64 time=3D0.4 ms
64 bytes from 129.206.21.202: icmp_seq=3D5 ttl=3D64 time=3D0.4 ms



Thanks,
 Bernd

--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
