From: Andrew Savchenko <Bircoph@list.ru>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Sat, 21 Jun 2008 04:04:01 +0400
Message-ID: <200806210404.10558.Bircoph@list.ru>
References: <200806201037.46687.Bircoph@list.ru> <84144f020806200412s5e0225eblbb2001ca139e7fdc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart28233583.XSXEtTLjSl";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	shemminger@vyatta.com, "Jeff Garzik" <jeff@garzik.org>,
	sorbica@icplus.com.tw, "Jesse Huang" <jesse@icplus.com.tw>
To: "Pekka Enberg" <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752306AbYFUAEc@vger.kernel.org>
In-Reply-To: <84144f020806200412s5e0225eblbb2001ca139e7fdc@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart28233583.XSXEtTLjSl
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Pekka,

On Friday 20 June 2008 15:12, Pekka Enberg wrote:
> Hi Andrew,
>
> (Please don't trim the cc.)

Oh, my apologies. I'm not subscribed to the list, so I mailed only=20
to emails found on lkml web page with original top mail.

> On Fri, Jun 20, 2008 at 9:37 AM, Andrew Savchenko=20
> <Bircoph@list.ru> wrote:=20
[...]
> As I don't have the hardware, I would appreciate if you could
> test the following quilt tree:
>
> =20
> http://www.kernel.org/pub/linux/kernel/people/penberg/patches/ip
>g/2.6.26-rc6/
>
> [Note: in case you're not familiar with quilt, the patches need
> to be applied in the order specified by the quilt 'series' file
> included there.]

Thanks for the advice. I installed quilt on my system and applied=20
your patchset to 2.6.26-rc6 kernel tree.

> You can enable 10KB jumbo frames either by passing:
>
>   ipg.jumbo=3D10k
>
> to the kernel command line or, alternatively, load the ipg
> module as follows:
>
>   modprobe ipg jumbo=3D10k
>
> You cannot enable or disable jumbo frame support once the module
> is loaded so if you want to try out different frame sizes, you
> first need to unload the module.

Ok, but in practice I need to reboot the system: 1) usually I=20
compile into the kernel all code related to frequently used=20
hardware. 2) This is a remote system, so reload of network module=20
which is in use will be quite tricky.

I tested it with both jumbo frames disabled (no options), and=20
enabled for 10k frames: ipg.jumbo=3D10k. It seems to work fine with=20
all acceptable MTUs (max MTU =3D=3D 10240).

Sincerely yours,
Andrew

--nextPart28233583.XSXEtTLjSl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBIXEVyAvwbVeyQBdURAgsZAJkBmkj3CabBhvbt0/yG0i86EO3zwQCgikrA
jshKoV/eoa7yLFk439pU3Xo=
=5c5x
-----END PGP SIGNATURE-----

--nextPart28233583.XSXEtTLjSl--
