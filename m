From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 12:36:38 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030123638.619f4de4@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
	<Xine.LNX.4.44.0410291342350.22168-100000@thoron.boston.redhat.com>
	<20041030091932.6a74bdae@zanzibar.2ka.mipt.ru>
	<20041030123449.5568d03f@zanzibar.2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Sat__30_Oct_2004_12_36_38_+0400_aA=4JPOYlB.TYYl="
Cc: James Morris <jmorris@redhat.com>, cryptoapi@lists.logix.cz,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041030123449.5568d03f@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Sat__30_Oct_2004_12_36_38_+0400_aA=4JPOYlB.TYYl=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Now attached needed file.

--- /dev/null	2004-09-17 14:58:06.000000000 +0400
+++ linux-2.6/drivers/acrypto/Kconfig	2004-10-30 12:32:53.000000000 +0400
@@ -0,0 +1,15 @@
+menu "Asynchronous crypto layer"
+
+config ACRYPTO
+	tristate "Asynchronous crypto layer"
+	depends on CONNECTOR && CRYPTO
+	---help---
+		Asynchronous crypto layer.
+
+config SIMPLE_LB
+	tristate "Simple load balancer"
+	depends on ACRYPTO
+	---help---
+		Simple load balancer.
+endmenu
+


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

--Multipart=_Sat__30_Oct_2004_12_36_38_+0400_aA=4JPOYlB.TYYl=
Content-Type: application/octet-stream;
 name="acrypto.patch.addon"
Content-Disposition: attachment;
 filename="acrypto.patch.addon"
Content-Transfer-Encoding: base64

LS0tIC9kZXYvbnVsbAkyMDA0LTA5LTE3IDE0OjU4OjA2LjAwMDAwMDAwMCArMDQwMAorKysgbGlu
dXgtMi42L2RyaXZlcnMvYWNyeXB0by9LY29uZmlnCTIwMDQtMTAtMzAgMTI6MzI6NTMuMDAwMDAw
MDAwICswNDAwCkBAIC0wLDAgKzEsMTUgQEAKK21lbnUgIkFzeW5jaHJvbm91cyBjcnlwdG8gbGF5
ZXIiCisKK2NvbmZpZyBBQ1JZUFRPCisJdHJpc3RhdGUgIkFzeW5jaHJvbm91cyBjcnlwdG8gbGF5
ZXIiCisJZGVwZW5kcyBvbiBDT05ORUNUT1IgJiYgQ1JZUFRPCisJLS0taGVscC0tLQorCQlBc3lu
Y2hyb25vdXMgY3J5cHRvIGxheWVyLgorCitjb25maWcgU0lNUExFX0xCCisJdHJpc3RhdGUgIlNp
bXBsZSBsb2FkIGJhbGFuY2VyIgorCWRlcGVuZHMgb24gQUNSWVBUTworCS0tLWhlbHAtLS0KKwkJ
U2ltcGxlIGxvYWQgYmFsYW5jZXIuCitlbmRtZW51CisK

--Multipart=_Sat__30_Oct_2004_12_36_38_+0400_aA=4JPOYlB.TYYl=--
