From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH] sfc: mtd: Use MTD_FAIL_ADDR_UNKNOWN instead of
 0xffffffff
Date: Mon, 13 Feb 2012 09:44:42 +0200
Message-ID: <1329119082.22240.108.camel@sauron.fi.intel.com>
References: <20120212111308.0267f200@pixies.home.jungo.com>
	 <20120213.005131.707348228946745194.davem@davemloft.net>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-AbiReZK+VGtY+c4ZOiFu"
Cc: shmulik.ladkani@gmail.com, bhutchings@solarflare.com,
	linux-net-drivers@solarflare.com, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42003 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab2BMHm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 02:42:29 -0500
Received: by pbcun15 with SMTP id un15so4340438pbc.19
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 23:42:28 -0800 (PST)
In-Reply-To: <20120213.005131.707348228946745194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AbiReZK+VGtY+c4ZOiFu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-02-13 at 00:51 -0500, David Miller wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Date: Sun, 12 Feb 2012 11:13:08 +0200
>=20
> > From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> >=20
> > As of bb0eb217, MTD_FAIL_ADDR_UNKNOWN should be used to indicate mtd
> > erase failure not specific to any particular block.
> >=20
> > Use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff when setting
> > 'erase->fail_addr' in 'efx_mtd_erase()'.
> >=20
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>=20
> Ben, what would you like me to do with this one?

Please, do nothing if you can, we'll handle this through the MTD tree,
thanks.

--=20
Best Regards,
Artem Bityutskiy

--=-AbiReZK+VGtY+c4ZOiFu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJPOL9qAAoJECmIfjd9wqK0aPgQAJUYOBoZSjVr8sXDb3TdFOlL
SiUp1IHX9rIOAQpKeZm0BQKjZSaCeI7TS4ZhIpr/EzEqYqG9t1/P5PR2Vt80xQBJ
OmVMeriozT7gdBZfWIFC4xPCOThi12X0SEsag/DFeDUtAxMTeLL/ZUKW6DxChCPZ
yW3K8FLQQiblZHN4lgcpNU5QncDyr0NNUoTdyO57igL6RB28L6oLYG71abZiMe/k
0+3wkjtTZTP59qsttyHwWw1rWoYTdXUTCncgDXnhLTnvW9DXm4hIzQHDjle8fiA7
qE2rZxANfH7X4oPFkDEStEbaSVEkSr3foBpME/ogHFndKUJSED+uUtngmfptHsvC
lJot6EQPwBSTitXnOSc/sF6yscJxKFtq2eD2gM6YgURrT7doPQbMvw7tAg7wyRLa
0wd4Q65eXObg1fowbFdpDo8GmQ2CFnSu1MPv/I4D96r8UErD1z7suM7NETYQFYnZ
RYoXdrwAEzuau983qfWOSAA5jPdwWDF7ush2avrir6tQvuAE182vYycODMr8skMU
J3hUvjKOsixtOR1LkMHX+O4EDeTe+iNcBrVsHDM+QZDpwhehiJKoJrhwoQGYFVM5
9yMIOBAOjultnFMGfoutVnJHqpu1Si0ZTfKWbX8k3G91TEzEotn+wZ9oOcI7UqJx
wL9lBjCbMKKFCohsOVIq
=niE4
-----END PGP SIGNATURE-----

--=-AbiReZK+VGtY+c4ZOiFu--
