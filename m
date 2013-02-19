From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 15:38:09 +0200
Message-ID: <20130219133809.GA4390@arwen.pp.htv.fi>
References: <20130219070310.2cadad7a@redhat.com>
 <20130219101121.GJ23197@arwen.pp.htv.fi>
 <20130219081149.46972f56@redhat.com>
 <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
 <20130219132853.GG26623@pd.tnic>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bp/iNruPH9dso1Pn"
To: Borislav Petkov <bp@alien8.de>, Felipe Balbi <balbi@ti.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:34210 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932753Ab3BSNjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 08:39:22 -0500
Content-Disposition: inline
In-Reply-To: <20130219132853.GG26623@pd.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 02:28:54PM +0100, Borislav Petkov wrote:
> On Tue, Feb 19, 2013 at 03:15:00PM +0200, Felipe Balbi wrote:
> > what's the problem with that ?
>=20
> Not a problem - simply annoying.
>=20
> $ ./test.sh
> cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
> Setting scrubrate to:
>=20
> I'm sure someone would ask themselves why all of a sudden the file is
> gone.
>=20
> > $ cat /path/to/file/that/doesnt/exist.txt
> > cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
> >=20
> > Didn't see any gates to hell opening here...
>=20
> And I don't see why we have to debate such a trivial thing when we can
> fix it *properly* without *absolutely* *not* upsetting userspace.

because changing the permission will cause the same issue:

$ cat temporary.txt=20
cat: temporary.txt: Permission denied
$ ls -l temporary.txt=20
---------- 1 balbi balbi 0 Feb 19 15:37 temporary.txt
$ cat temporary.txt=20
cat: temporary.txt: Permission denied
$ cat non-existent.txt
cat: non-existent.txt: No such file or directory

just a different error code is returned...

--=20
balbi

--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI4BBAAoJEIaOsuA1yqREk08P/3ty8uikzGRMcoaDI6aVGBW5
UHlJQga00Y7bMpZmhdTWleB92rsFvwcOL53Yc6YYCwcTgHkYE8dcAYALRfVpO4Y0
kNq/wtMSXqx7H1JBo15pm2XIq6FLUudZkXOCjKiBG/miVDqogzINUZ758ofcXelY
wOeYMs5WKUxdkj41oqgN624gwyf/O81VT1paQ4eSXr1zTCjWx8KJz7JZkQY+daZn
3panntFRUJvDDWsrZ1fKoztxaWAO0s3pyctT8yXJYv9o1JVDjADtkNgMSqVxF+0m
zD+fHhmPTT627ZE3gmwmw2rk0jcqCYMjBMp2OuFlqeNivSKLXs03BRisvq8g3IUI
pcFNmbVaF7vJ6Oam6CO7zpOPgykmxWb4oRqFBXMri5biY0it3KicIxeL8ZnqMU/o
OXpKrF5W50bd0CfQTH9kEd6g/a/nmTWXA9hCTVzpH7Ln//njmBA3nDp7ciXL2J6F
krgdK9wtXSfxf2fs8AGldw05FO2rwq45dhFvohDZXCP34pYvqTDCK+iAOC+Xmvxm
tw8dUrs3L/Pm0U97e7FW4peJBmjuDHB6WU9Q4PNXedkuiE3qK8/5VzsB+bzGEnsD
HASmiR+0d2m2LzWwVa+y2kIJ/ByNBbiHbMsbb3XTWdHqVPPuPkGEfbIJvdjI0+7N
t2F+JanJfKfUMHEDaWVb
=oWer
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--
