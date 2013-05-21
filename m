From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/5] perf: net_dropmonitor: Fix trace parameter order
Date: Tue, 21 May 2013 01:44:43 +0100
Message-ID: <1369097083.3469.132.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jQhIYaWgKswFCItxTi8/"
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	708994@bugs.debian.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jQhIYaWgKswFCItxTi8/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This works much better if we don't treat protocol numbers as addresses.

Cc: stable@vger.kernel.org
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 tools/perf/scripts/python/net_dropmonitor.py |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/perf/scripts/python/net_dropmonitor.py b/tools/perf/scri=
pts/python/net_dropmonitor.py
index a4ffc95..adbfbf0 100755
--- a/tools/perf/scripts/python/net_dropmonitor.py
+++ b/tools/perf/scripts/python/net_dropmonitor.py
@@ -64,7 +64,7 @@ def trace_end():
=20
 # called from perf, when it finds a correspoinding event
 def skb__kfree_skb(name, context, cpu, sec, nsec, pid, comm,
-			skbaddr, protocol, location):
+		   skbaddr, location, protocol):
 	slocation =3D str(location)
 	try:
 		drop_log[slocation] =3D drop_log[slocation] + 1



--=-jQhIYaWgKswFCItxTi8/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZrDe+e/yOyVhhEJAQrIfhAAluj6brW3+KFCmXoSuu/F3LWFDTNB5JGf
lrxu3bw0fhJQq6wlDpeQRrvutPhKq9D6j6F8oB8BrOvYlrGAK9S5YYsOsXlJYQAx
XGT5jYwmTtS5ZONGFhxJkwJdd0yR4MBGuthYQ4HLi8gquwzamno+us/ebyEXEoy0
79J5Ta/UGNDRljG0mySthNBJNZVQu3YUcHhMmEMYJA+YAzqF6MsxBAb1j1NYMXhD
Fo83D33bhYkdETKzhnLT/jiuDxsHLCDwPa4w1yDyJ+xSq4nA6lM5CwlnjT0+nbBR
qtgJFczzr3lj5KkDntcuKfeoSd3hMz0GOZxNoctUsYU5N4/0SnuoAuUYfnz3xkIJ
YMhOUIDIHIIMYc7R1snduEezU0rRkegFwerSVhNDe/h9QccZhCy+Y++7zqP+dR7o
2XK69HDBcIlXs7A9L4uLWsu0xeAg2y0axO1e0cw7utfNaOxVYp7F8232j8w4+bkf
q/Nk7QI8nQPakWyGT01gVPOAZ4uMipxDas3cGG60Jmgw8nZ0loncrzbv16sFh4v0
q0OKQntrph8H7od3TDyF+snxURrCoGMG9FQ6wem7ne6ah+T8z4wINZIiryj/4Hsz
qr2iuaeFAjjWRTftd7soGr1dJ93aMUNDIRP5hNQxMwlnimSJX8fU2JCxK0YKKBXB
T0haSfBvcIs=
=FJ3U
-----END PGP SIGNATURE-----

--=-jQhIYaWgKswFCItxTi8/--
