From: Stephen Waters <swaters@amicus.com>
Subject: [Fwd: Re: macmace transmit timeout]
Date: 11 Nov 2002 22:37:42 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1037075862.3036.21.camel@arrakeen>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-lPHg0K8L+jGol/37CcXo"
Cc: Ben Stanley <bds02@uow.edu.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-lPHg0K8L+jGol/37CcXo
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ben, I'm forwarding this to netdev in hopes someone there might have a
clue...

-s

Ben Stanley wrote:
>=20
> Kernel version:
>=20
> Linux version 2.4.20-pre4 (kato@hiryu) (gcc version 2.95.4 20010319
> (prerelease/franzo/20010623)) #1 2002=C7=AF 8=B7=EE 20=C6=FC =B2=D0=CD=CB=
=C6=FC 12:25:37 JST
> it was built by Etsushi Kato, so it's the file
> MachKernel-2.4.20-pre4-020820=20
> from his ftp site.
>=20
> This message has been in the kernel ever since I started using the
> nubus-pmac port about 2 years ago.
>=20
> Network setup:
>=20
>      --------------------------------------------------------------
>      |                 |                         |                |
> 192.168.1.2        192.168.12               192.168.1.13     192.168.1.1
> nfs and x server   mp3 player (6100/66)      xterminal         firewall
>   dragon            kangaeru                  komodo            ipcop
>                                                         xxx.xxx.xxx.xxx
>                                                                   |
>                                              outside world --------
>=20
>=20
> There's lots of traffic on the network when the x terminal is in use.
> The network uses hubs, not switches.
>=20
> kernel startup detects the network controller as:
> Nov 12 10:58:40 kangaeru kernel: eth0: MACE at 08:00:07:37:04:95, chip
> revision 0x0940
>=20
> The problem hasn't happened today, and I didn't notice it happen while
> it was playing all day yesterday. It's quite intermittent. However,
> yesterday's logs are full of the message:
>=20
> Nov 11 17:30:35 kangaeru kernel: macmace: transmit timeout - resetting
> Nov 11 18:01:35 kangaeru kernel: macmace: transmit timeout - resetting
> Nov 11 18:21:07 kangaeru kernel: macmace: transmit timeout - resetting
> Nov 11 18:22:57 kangaeru kernel: macmace: transmit timeout - resetting
> Nov 11 18:27:41 kangaeru kernel: macmace: transmit timeout - resetting
>=20
> So maybe there is no association after all. I'm not sure.
>=20
> Ben.
>=20
> On Tue, 2002-11-12 at 01:54, Stephen Waters wrote:
> >=20
> > kernel version? your network setup?
> >=20
> > On Sat, 2002-11-09 at 19:55, Ben Stanley wrote:
> > >
> > > I use my 6100/66 as a network mp3 player, and periodically it stops f=
or
> > > about 30 seconds, for no apparent reason.  checked the logs, and at
> > > about the time of the silence, I see this message:
> > >
> > > Nov 10 12:29:37 kangaeru kernel: macmace: transmit timeout - resetting
> > >
> > > what's going on?


--=-lPHg0K8L+jGol/37CcXo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA90IWWvSyJ32tBS68RAgL6AKCtFc+0Y28Ew5/0o5BGZ7jCZwzr5wCg3br4
55bituQxOVyOB/o1V6RMwF8=
=VLGN
-----END PGP SIGNATURE-----

--=-lPHg0K8L+jGol/37CcXo--
