From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the
 sparc-next tree
Date: Thu, 17 May 2012 13:04:06 +1000
Message-ID: <20120517130406.1706f944820bbe8dc5e368f2@canb.auug.org.au>
References: <20120516143944.57a648287aa5cd1a5930254e@canb.auug.org.au>
	<20120516050245.GA407@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__17_May_2012_13_04_06_+1000_jDNbI=6r.5a6Y.oC"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120516050245.GA407@merkur.ravnborg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__17_May_2012_13_04_06_+1000_jDNbI=6r.5a6Y.oC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sam,

On Wed, 16 May 2012 07:02:45 +0200 Sam Ravnborg <sam@ravnborg.org> wrote:
>
> On Wed, May 16, 2012 at 02:39:44PM +1000, Stephen Rothwell wrote:
> > Hi all,
> >=20
> > Today's linux-next merge of the net-next tree got a conflict in
> > arch/sparc/Makefile between commit e1d7de8377e6 ("sparc: introduce
> > arch/sparc/Kbuild") from the sparc-next tree and commit 2809a2087cc4
> > ("net: filter: Just In Time compiler for sparc") from the net-next tree.
> >=20
> > I suspect that the core-y net bit below should be changed to be a obj-y
> > bit of arch/sparc/Kbuild ...
>=20
> Correct - like this:
>=20
> arch/sparc/Kbuild:
>=20
> obj-y +=3D net/

So I applied this merge fixup to the merge of the net-next tree today
(and can carry it as necessary):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 17 May 2012 13:00:07 +1000
Subject: [PATCH] net: arch/sparc/Makefile merge fixup

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 arch/sparc/Kbuild   |    1 +
 arch/sparc/Makefile |    1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sparc/Kbuild b/arch/sparc/Kbuild
index 27b540d..5cd0116 100644
--- a/arch/sparc/Kbuild
+++ b/arch/sparc/Kbuild
@@ -5,3 +5,4 @@
 obj-y +=3D kernel/
 obj-y +=3D mm/
 obj-y +=3D math-emu/
+obj-y +=3D net/
diff --git a/arch/sparc/Makefile b/arch/sparc/Makefile
index 554e38f..b9a72e2 100644
--- a/arch/sparc/Makefile
+++ b/arch/sparc/Makefile
@@ -54,7 +54,6 @@ head-y                 +=3D arch/sparc/kernel/init_task.o
=20
 # See arch/sparc/Kbuild for the core part of the kernel
 core-y                 +=3D arch/sparc/
-core-y                 +=3D arch/sparc/net/
=20
 libs-y                 +=3D arch/sparc/prom/
 libs-y                 +=3D arch/sparc/lib/
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__17_May_2012_13_04_06_+1000_jDNbI=6r.5a6Y.oC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPtGqmAAoJEECxmPOUX5FEf1oP/RVPSicSn/BKcefKBgT7xrJi
FhibRzRu7BhbY9PbNNb/7AhqNYp3wSb4ENZDnhhEchaXRRlLmFQpOoc0waGmRj4V
I5ATnNDTocAbwRlXrQIFzyj641dXjWzCd3SL3cQ7p4KHeXEw4SvaITc8Pd9DL644
J7kVAvTxvcQue9JgCltq1cHvVe7Rr2rHMXQuVoCFg1GN6L9m4WmCe9/HxYUbpECv
vpGQcZ80Rl0TNx6K4ubqMNJk90EAoe0QtTgLIoNnQhOoPpTdUYoC0/Leu02ypN1s
yJjYapzqLSSLfuOLTX8mnwgLjL0M5Q7cfAA+coxoiKeAsG0yCcPP0gwIkLGTViqK
1R96+XKQ3gwmEN1T8fL5nJ3gSbNzsG2Pq4OTTX6EP4yPzW1BvQW+YKvz4/C6zKXv
eOie7RmdJ9lCcBSD9w3AsGh2prPNXkkYhIPTSUcgqfwgIURj835uIEV7VfK/VT75
T4GZOJqbR+SdJKFYD7X+z5jdpHh6lgpAMJM2d2jcy9qCcZiZ7+Khd3Zu2FrQv4jA
rceezhCw341gG4DjRaiAcVKxLkF3VUvQ7VfPTiMuuCmeHBqhiUttv9z5wXlmO1Df
6RKjSe3vxPcD/tyvSabdqCSIQnEM/jV7+dk/7H6oN33GYJ6W/4RFgbigWEUi2Ll9
9h6PWu2DHdhlDOESi5oP
=d23S
-----END PGP SIGNATURE-----

--Signature=_Thu__17_May_2012_13_04_06_+1000_jDNbI=6r.5a6Y.oC--
