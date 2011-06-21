From: Ken Ballentine <coop2-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org>
Subject: [PATCH] mcp251x: Fix duplicate transmissions
Date: Tue, 21 Jun 2011 13:28:34 -0400
Message-ID: <BANLkTimfp4wnOR=OTYqFMtSO==XXU4WgvA@mail.gmail.com>
Reply-To: ken.ballentine-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec5299fd37294f104a63c2e3c
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

--bcaec5299fd37294f104a63c2e3c
Content-Type: multipart/alternative; boundary=bcaec5299fd37294ec04a63c2e3a

--bcaec5299fd37294ec04a63c2e3a
Content-Type: text/plain; charset=ISO-8859-1

Use the RTS SPI instruction instead of setting the TXREQ bit. This works
around errata item 5 for the MCP2515, as described by Microchip in
http://ww1.microchip.com/downloads/en/DeviceDoc/80179g.pdf.

Signed-off-by: Ken Ballentine <ken.ballentine-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org>
Signed-off-by: Michael Williamson <michael.williamson-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org>

--bcaec5299fd37294ec04a63c2e3a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Use the RTS SPI instruction instead of setting the TXREQ bit. This works ar=
ound errata item 5 for the MCP2515, as described by Microchip in <a href=3D=
"http://ww1.microchip.com/downloads/en/DeviceDoc/80179g.pdf">http://ww1.mic=
rochip.com/downloads/en/DeviceDoc/80179g.pdf</a>.<br clear=3D"all">
<br>Signed-off-by: Ken Ballentine &lt;<a href=3D"mailto:ken.ballentine@crit=
icallink.com">ken.ballentine-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org</a>&gt;<br>Signed-off-by: Mic=
hael Williamson &lt;<a href=3D"mailto:michael.williamson-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org">=
michael.williamson-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org</a>&gt;<br>


--bcaec5299fd37294ec04a63c2e3a--

--bcaec5299fd37294f104a63c2e3c
Content-Type: application/octet-stream; name="mcp251x.patch"
Content-Disposition: attachment; filename="mcp251x.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gp74o22f0

ZGlmZiAtdU5yIGxpbnV4LTIuNi4zOS4xLm9yaWcvZHJpdmVycy9uZXQvY2FuL21jcDI1MXguYyBs
aW51eC0yLjYuMzkuMS5uZXcvZHJpdmVycy9uZXQvY2FuL21jcDI1MXguYwotLS0gbGludXgtMi42
LjM5LjEub3JpZy9kcml2ZXJzL25ldC9jYW4vbWNwMjUxeC5jCTIwMTEtMDYtMDIgMjA6MzQ6MjAu
MDAwMDAwMDAwIC0wNDAwCisrKyBsaW51eC0yLjYuMzkuMS5uZXcvZHJpdmVycy9uZXQvY2FuL21j
cDI1MXguYwkyMDExLTA2LTIxIDEyOjA3OjQzLjcyMDcwODkwNyAtMDQwMApAQCAtODIsNiArODIs
NyBAQAogI2RlZmluZSBJTlNUUlVDVElPTl9CSVRfTU9ESUZZCTB4MDUKICNkZWZpbmUgSU5TVFJV
Q1RJT05fTE9BRF9UWEIobikJKDB4NDAgKyAyICogKG4pKQogI2RlZmluZSBJTlNUUlVDVElPTl9S
RUFEX1JYQihuKQkoKChuKSA9PSAwKSA/IDB4OTAgOiAweDk0KQorI2RlZmluZSBJTlNUUlVDVElP
Tl9SVFMobikJKDB4ODAgfCAoMSA8PCBuKSkKICNkZWZpbmUgSU5TVFJVQ1RJT05fUkVTRVQJMHhD
MAogCiAvKiBNUEMyNTF4IHJlZ2lzdGVycyAqLwpAQCAtMzc3LDYgKzM3OCwxNSBAQAogCW1jcDI1
MXhfc3BpX3RyYW5zKHNwaSwgNCk7CiB9CiAKK3N0YXRpYyB2b2lkIG1jcDI1MXhfd3JpdGVfcnRz
KHN0cnVjdCBzcGlfZGV2aWNlICpzcGksIGludCB0eF9idWZfaWR4KQoreworCXN0cnVjdCBtY3Ay
NTF4X3ByaXYgKnByaXYgPSBkZXZfZ2V0X2RydmRhdGEoJnNwaS0+ZGV2KTsKKworCXByaXYtPnNw
aV90eF9idWZbMF0gPSBJTlNUUlVDVElPTl9SVFModHhfYnVmX2lkeCk7CisKKwltY3AyNTF4X3Nw
aV90cmFucyhzcGksIDEpOworfQorCiBzdGF0aWMgdm9pZCBtY3AyNTF4X2h3X3R4X2ZyYW1lKHN0
cnVjdCBzcGlfZGV2aWNlICpzcGksIHU4ICpidWYsCiAJCQkJaW50IGxlbiwgaW50IHR4X2J1Zl9p
ZHgpCiB7CkBAIC00MTgsNyArNDI4LDcgQEAKIAlidWZbVFhCRExDX09GRl0gPSAocnRyIDw8IERM
Q19SVFJfU0hJRlQpIHwgZnJhbWUtPmNhbl9kbGM7CiAJbWVtY3B5KGJ1ZiArIFRYQkRBVF9PRkYs
IGZyYW1lLT5kYXRhLCBmcmFtZS0+Y2FuX2RsYyk7CiAJbWNwMjUxeF9od190eF9mcmFtZShzcGks
IGJ1ZiwgZnJhbWUtPmNhbl9kbGMsIHR4X2J1Zl9pZHgpOwotCW1jcDI1MXhfd3JpdGVfcmVnKHNw
aSwgVFhCQ1RSTCh0eF9idWZfaWR4KSwgVFhCQ1RSTF9UWFJFUSk7CisJbWNwMjUxeF93cml0ZV9y
dHMoc3BpLCB0eF9idWZfaWR4KTsKIH0KIAogc3RhdGljIHZvaWQgbWNwMjUxeF9od19yeF9mcmFt
ZShzdHJ1Y3Qgc3BpX2RldmljZSAqc3BpLCB1OCAqYnVmLAo=
--bcaec5299fd37294f104a63c2e3c
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--bcaec5299fd37294f104a63c2e3c--
