From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/3 net-next] e1000: Allocate
 pm_qos_req as needed
Date: Thu, 09 Apr 2015 21:35:39 -0700
Message-ID: <1428640539.2729.67.camel@jtkirshe-mobl>
References: <cover.1428622095.git.tgraf@suug.ch>
	 <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>
	 <1428624503.2729.55.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GfTdHsUcCINnAizuCMss"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34228 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbbDJEfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 00:35:42 -0400
In-Reply-To: <1428624503.2729.55.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GfTdHsUcCINnAizuCMss
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-04-09 at 17:08 -0700, Jeff Kirsher wrote:
> On Fri, 2015-04-10 at 01:43 +0200, Thomas Graf wrote:
> > e1000 is the only driver requiring pm_qos_req, instead of causing
> > every device to waste up to 240 bytes. Allocate it for the specific
> > driver.
> >=20
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> >  drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++----
> >  include/linux/netdevice.h                  |  2 +-
> >  2 files changed, 12 insertions(+), 5 deletions(-)
>=20
> Small nitpick, it is e1000e not e1000 that you are modifying.

So other than the patch title and description referencing e1000 instead
of e1000e, patch looks fine.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-GfTdHsUcCINnAizuCMss
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJ1MbAAoJEOVv75VaS+3OBqYP/0JJwmgVhFWn5yRsQn+kJwas
q7WKSEwuZbZOd1IIOzEZ36UOfgw7wqbLqi0VtGcOtV2xAI6f9MBWPjaFt6U3/f2x
OrDwDxDbsADqrgBNMivIuD6odqG5csVxHVxKZ4HeT49aCInpkkXMcvS/yJGHSfVY
giQ3lLtf3drSCQfxCnQPEfDOpZvtLF9QU6uoOH1bhsgx0+AjKDB7y1EFIb8j5JkW
82femeEpl2NFCfqtLJ3ehXS4qMdaPhoJfMorIu4/zsY0ysS9t2JFWJ1LolJSvHxE
gDFticqFiTa0FDp2bRSwykyXk5FF0T+v7UC3Gt0KkfZMakgwKKn9ixlFpE4Kqh1y
bQp1kVF1QFXrdO4lO5uyDIzxYkC9/QgKryu7hW5K4bPkBg0/saUNT76VDiQ4zFXH
zUPy40fy9Lqm0lrdyCvmZ1dFDlFBkWEklr+cyLY4sopB7A4+rc2Jys3xYMU4Uh0H
/PRfpL39YOz6myi0G9UV/rpLzRB9gwQPbnRTo6FYmIpvFAvpOKCpGQpt8nIrbk5Q
zQqP+oUW3ERhKyAtklWxxUGKf3zJU4HD6bOpyQhVn/32Kdxb8HcnlEQSzfoMcQtL
8Bv/9p4QPpSMvVUmefeFFbNrjTpTwxh47TJfHWsB+FkWR83iR843dQcdRyHCsuFc
w4CY8QWUVS+I9v+3dJPt
=nhU/
-----END PGP SIGNATURE-----

--=-GfTdHsUcCINnAizuCMss--
