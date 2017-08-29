From: Andreas Ziegler <andreas.ziegler@fau.de>
Subject: Re: staging: r8822be: Add code for halmac sub-driver
Date: Tue, 29 Aug 2017 12:59:27 +0200
Message-ID: <0758af1e-f8d5-97be-8308-ba5535ab9415@fau.de>
References: <20170817174652.17656-5-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms070509090600040403040709"
Cc: gregkh@linuxfoundation.org,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        Shaofu <shaofu@realtek.com>,
        Steven Ting <steventing@realtek.com>,
        netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org
To: Ping-Ke Shih <pkshih@realtek.com>,
        Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-rz-3.rrze.uni-erlangen.de ([131.188.11.22]:50048 "EHLO
        mx-rz-3.rrze.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751485AbdH2LFD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 07:05:03 -0400
In-Reply-To: <20170817174652.17656-5-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms070509090600040403040709
Content-Type: multipart/mixed;
 boundary="------------0F06B0442C6A49007D59084A"
Content-Language: de-DE

This is a multi-part message in MIME format.
--------------0F06B0442C6A49007D59084A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Ping-Ke, hi Larry,

I noticed your commit in linux-next today using the in-tree script at
scripts/checkkconfigsymbols.py [0]. The script showed that it uses
CONFIG_RTL_DEBUG in an #ifdef statement - this symbol, however, does not =
exist,
and should probably be CONFIG_RTLWIFI_DEBUG instead.

I attached a patch which fixes this problem.

Best regards,

Andreas Ziegler

[0]: I called the script like this: './scripts/checkkconfigsymbols.py --f=
orce -c
938a0447f094'

--------------0F06B0442C6A49007D59084A
Content-Type: text/x-patch;
 name="0001-staging-r8822be-Fix-typo-for-CONFIG_RTLWIFI_DEBUG.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-staging-r8822be-Fix-typo-for-CONFIG_RTLWIFI_DEBUG.patch"

=46rom 6c713900ed877c01f94fb76630f9ffd32c73ec88 Mon Sep 17 00:00:00 2001
From: Andreas Ziegler <andreas.ziegler@fau.de>
Date: Tue, 29 Aug 2017 12:50:37 +0200
Subject: [PATCH] staging: r8822be: Fix typo for CONFIG_RTLWIFI_DEBUG

The debugging output in deinit_priv is guarded by an  #ifdef using
CONFIG_RTL_DEBUG. This symbol does not exist and should be
CONFIG_RTLWIFI_DEBUG instead.

Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>
---
 drivers/staging/rtlwifi/halmac/rtl_halmac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtlwifi/halmac/rtl_halmac.c b/drivers/stagin=
g/rtlwifi/halmac/rtl_halmac.c
index 031bf2c..888ca43 100644
--- a/drivers/staging/rtlwifi/halmac/rtl_halmac.c
+++ b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
@@ -386,7 +386,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
 		u32 count, size;
=20
 		count =3D HALMAC_FEATURE_ALL + 1;
-#ifdef CONFIG_RTL_DEBUG
+#ifdef CONFIG_RTLWIFI_DEBUG
 		{
 			struct submit_ctx *sctx;
 			u32 i;
@@ -405,7 +405,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
 				rtl_mfree((u8 *)sctx, sizeof(*sctx));
 			}
 		}
-#endif /* !CONFIG_RTL_DEBUG */
+#endif /* !CONFIG_RTLWIFI_DEBUG */
 		size =3D sizeof(*indicator) * count;
 		kfree((u8 *)indicator);
 	}
--=20
2.7.4


--------------0F06B0442C6A49007D59084A--

--------------ms070509090600040403040709
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
ELswggTVMIIDvaADAgECAghQTsb1PRG0ZDANBgkqhkiG9w0BAQsFADBxMQswCQYDVQQGEwJE
RTEcMBoGA1UEChMTRGV1dHNjaGUgVGVsZWtvbSBBRzEfMB0GA1UECxMWVC1UZWxlU2VjIFRy
dXN0IENlbnRlcjEjMCEGA1UEAxMaRGV1dHNjaGUgVGVsZWtvbSBSb290IENBIDIwHhcNMTQw
NzIyMTIwODI2WhcNMTkwNzA5MjM1OTAwWjBaMQswCQYDVQQGEwJERTETMBEGA1UEChMKREZO
LVZlcmVpbjEQMA4GA1UECxMHREZOLVBLSTEkMCIGA1UEAxMbREZOLVZlcmVpbiBQQ0EgR2xv
YmFsIC0gRzAxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6ZvDZ4X5Da71jVTD
llA1PWLpbkztlNcAW5UidNQg6zSP1uzAMQQLmYHiphTSUqAoI4SLdIkEXlvg4njBeMsWyyg1
OXstkEXQ7aAAeny/Sg4bAMOG6VwrMRF7DPOCJEOMHDiLamgAmu7cT3ir0sYTm3at7t4m6O8B
r3QPwQmi9mvOvdPNFDBP9eXjpMhim4IaAycwDQJlYE3t0QkjKpY1WCfTdsZxtpAdxO3/NYZ9
bzOz2w/FEcKKg6GUXUFr2NIQ9Uz9ylGs2b3vkoO72uuLFlZWQ8/h1RM9ph8nMM1JVNvJEzSa
cXXFbOqnC5j5IZ0nrz6jOTlIaoytyZn7wxLyvQIDAQABo4IBhjCCAYIwDgYDVR0PAQH/BAQD
AgEGMB0GA1UdDgQWBBRJt8bP6D0ff+pEexMp9/EKcD7eZDAfBgNVHSMEGDAWgBQxw3kbuvVT
1xfgiXotF2wKsyudMzASBgNVHRMBAf8ECDAGAQH/AgECMGIGA1UdIARbMFkwEQYPKwYBBAGB
rSGCLAEBBAICMBEGDysGAQQBga0hgiwBAQQDADARBg8rBgEEAYGtIYIsAQEEAwEwDwYNKwYB
BAGBrSGCLAEBBDANBgsrBgEEAYGtIYIsHjA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vcGtp
MDMzNi50ZWxlc2VjLmRlL3JsL0RUX1JPT1RfQ0FfMi5jcmwweAYIKwYBBQUHAQEEbDBqMCwG
CCsGAQUFBzABhiBodHRwOi8vb2NzcDAzMzYudGVsZXNlYy5kZS9vY3NwcjA6BggrBgEFBQcw
AoYuaHR0cDovL3BraTAzMzYudGVsZXNlYy5kZS9jcnQvRFRfUk9PVF9DQV8yLmNlcjANBgkq
hkiG9w0BAQsFAAOCAQEAYyAo/ZwhhnK+OUZZOTIlvKkBmw3Myn1BnIZtCm4ssxNZdbEzkhth
Jxb/w7LVNYL7hCoBSb1mu2YvssIGXW4/buMBWlvKQ2NclbbhMacf1QdfTeZlgk4y+cN8ekvN
TVx07iHydQLsUj7SyWrTkCNuSWc1vn9NVqTszC/Pt6GXqHI+ybxA1lqkCD3WvILDt7cyjrEs
jmpttzUCGc/1OURYY6ckABCwu/xOr24vOLulV0k/2G5QbyyXltwdRpplic+uzPLl2Z9Tsz6h
L5Kp2AvGhB8Exuse6J99tXulAvEkxSRjETTMWpMgKnmIOiVCkKllO3yG0xIVIyn8LNrMOVtU
FzCCBYUwggRtoAMCAQICBxekJTUNxL8wDQYJKoZIhvcNAQELBQAwWjELMAkGA1UEBhMCREUx
EzARBgNVBAoTCkRGTi1WZXJlaW4xEDAOBgNVBAsTB0RGTi1QS0kxJDAiBgNVBAMTG0RGTi1W
ZXJlaW4gUENBIEdsb2JhbCAtIEcwMTAeFw0xNDA1MjcxNDU2MzdaFw0xOTA3MDkyMzU5MDBa
MIGjMQswCQYDVQQGEwJERTEPMA0GA1UECBMGQmF5ZXJuMREwDwYDVQQHEwhFcmxhbmdlbjEo
MCYGA1UEChMfVW5pdmVyc2l0YWV0IEVybGFuZ2VuLU51ZXJuYmVyZzENMAsGA1UECxMEUlJa
RTEPMA0GA1UEAxMGRkFVLUNBMSYwJAYJKoZIhvcNAQkBFhdjYUBycnplLnVuaS1lcmxhbmdl
bi5kZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALeM6O3UbAkUYBzi+4jBEF8F
klzGxWvAHHou8+iNKcRVMU9fMiuJ/n4KuH/3AgzGloyieClmOqe/KlIhWURtMwsOmD3rMclX
p9ilG7eIU70uE82az1Cw7N2V3o9tlIPlDH61ZXK8XCQO05u/zubqLREeOidcV+irlur548hu
y+iURMGuowGgH1tm9l1X3735XqkvkFwnUzUkhFiABwtajxIZ022gMCJba5RXj+LSZv+67MPT
qQmdoMf3WSs8zpM854+RSSPNbinKDo4KARkfaNkTib36HPMfMTu5ViBR5TIuRJ/gAHtV3YC+
Uccjpj/y4XUN+EoqsqODlFsVv994KAkCAwEAAaOCAgQwggIAMBIGA1UdEwEB/wQIMAYBAf8C
AQEwDgYDVR0PAQH/BAQDAgEGMBEGA1UdIAQKMAgwBgYEVR0gADAdBgNVHQ4EFgQU9HPz+sZC
s8ZcacBYvnQ4+WErjmIwHwYDVR0jBBgwFoAUSbfGz+g9H3/qRHsTKffxCnA+3mQwIgYDVR0R
BBswGYEXY2FAcnJ6ZS51bmktZXJsYW5nZW4uZGUwgYgGA1UdHwSBgDB+MD2gO6A5hjdodHRw
Oi8vY2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2FjcmwuY3JsMD2g
O6A5hjdodHRwOi8vY2RwMi5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jcmwvY2Fj
cmwuY3JsMIHXBggrBgEFBQcBAQSByjCBxzAzBggrBgEFBQcwAYYnaHR0cDovL29jc3AucGNh
LmRmbi5kZS9PQ1NQLVNlcnZlci9PQ1NQMEcGCCsGAQUFBzAChjtodHRwOi8vY2RwMS5wY2Eu
ZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBHBggrBgEFBQcw
AoY7aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1jYS9wdWIvY2FjZXJ0L2Nh
Y2VydC5jcnQwDQYJKoZIhvcNAQELBQADggEBAAvdv5tQXS8Y3D2t/HCEcmY7UzcK/b8XU6IY
0o8b25SNIVX0qkNyC6nkx2NJNpas2cCVs5PgKmAV59oCiNupcUBJ126wiTlzuy4wI1YSJgHw
PX0rEMLefI/6YAfxgCqH0fcRy0WS845CSZNY7raVwyZBjrvCYio0i2jmniSAT6RPfWATXsrB
l3gmfBtJ7OFt0l1zLeKhhPhMeIUMojGUKsdyMslBC6Qm5UDA/N683/eGCfk3KOwKVQZ06hml
bEDwfa8j70R3XFmOVDCKcXJWlTRA/TAExQCz4Y0AWoZJ76PdMzQtjIKpvBq2Kh4L8D5azsp0
lBqMJ/8X8jD51omx47cwggZVMIIFPaADAgECAgwclFi/j/PFlOAOvOwwDQYJKoZIhvcNAQEL
BQAwgaMxCzAJBgNVBAYTAkRFMQ8wDQYDVQQIEwZCYXllcm4xETAPBgNVBAcTCEVybGFuZ2Vu
MSgwJgYDVQQKEx9Vbml2ZXJzaXRhZXQgRXJsYW5nZW4tTnVlcm5iZXJnMQ0wCwYDVQQLEwRS
UlpFMQ8wDQYDVQQDEwZGQVUtQ0ExJjAkBgkqhkiG9w0BCQEWF2NhQHJyemUudW5pLWVybGFu
Z2VuLmRlMB4XDTE3MDExMDEzMDEzNVoXDTE5MDcwOTIzNTkwMFowgaAxCzAJBgNVBAYTAkRF
MQ8wDQYDVQQIDAZCYXllcm4xETAPBgNVBAcMCEVybGFuZ2VuMTwwOgYDVQQKDDNGcmllZHJp
Y2gtQWxleGFuZGVyLVVuaXZlcnNpdGFldCBFcmxhbmdlbi1OdWVybmJlcmcxFTATBgNVBAsM
DEluZm9ybWF0aWsgNDEYMBYGA1UEAwwPQW5kcmVhcyBaaWVnbGVyMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAmtyQgCgFPnLKIEH2ckMjkdT6/Z9QqAOAvLrD3CPGYVBjX60K
D/vNCSxjmiljAIgA12c8atTvXjm0MPicbp6G1HAwiOZHompyuab7gF8lMiR+6aQTNwawwMRY
lEeuXVxslwVu4kMu4N5AVid2VRgnodtMdEWzhlnRF1Z4wuY9egLYdZjVVJyWKPGDrgvREn9U
P5wjvR2IjnrrjXBcEb1StUIYnQGIWySb+TjNd+LAlFy6mBVWiDOaHZO7VTZmwQOl/ezw+8LZ
b7aVxTPZsJV/Jx4sNDt1XextSSCnGDYUVGSlOhNOeFzJufdNwW6O7ZlS/DT3d1/OLcjf37SA
XWB/qwIDAQABo4ICiDCCAoQwQAYDVR0gBDkwNzARBg8rBgEEAYGtIYIsAQEEAwUwEQYPKwYB
BAGBrSGCLAIBBAMBMA8GDSsGAQQBga0hgiwBAQQwCQYDVR0TBAIwADAOBgNVHQ8BAf8EBAMC
BeAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMB0GA1UdDgQWBBTgq5FcX/tTXVoT
pjxFcHQMQIw8NzAfBgNVHSMEGDAWgBT0c/P6xkKzxlxpwFi+dDj5YSuOYjA0BgNVHREELTAr
gRZhbmRyZWFzLnppZWdsZXJAZmF1LmRlgRF6aWVnbGVyQGNzLmZhdS5kZTCBnwYDVR0fBIGX
MIGUMEigRqBEhkJodHRwOi8vY2RwMS5wY2EuZGZuLmRlL3VuaS1lcmxhbmdlbi1udWVybmJl
cmctY2EvcHViL2NybC9jYWNybC5jcmwwSKBGoESGQmh0dHA6Ly9jZHAyLnBjYS5kZm4uZGUv
dW5pLWVybGFuZ2VuLW51ZXJuYmVyZy1jYS9wdWIvY3JsL2NhY3JsLmNybDCB7QYIKwYBBQUH
AQEEgeAwgd0wMwYIKwYBBQUHMAGGJ2h0dHA6Ly9vY3NwLnBjYS5kZm4uZGUvT0NTUC1TZXJ2
ZXIvT0NTUDBSBggrBgEFBQcwAoZGaHR0cDovL2NkcDEucGNhLmRmbi5kZS91bmktZXJsYW5n
ZW4tbnVlcm5iZXJnLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBSBggrBgEFBQcwAoZGaHR0
cDovL2NkcDIucGNhLmRmbi5kZS91bmktZXJsYW5nZW4tbnVlcm5iZXJnLWNhL3B1Yi9jYWNl
cnQvY2FjZXJ0LmNydDANBgkqhkiG9w0BAQsFAAOCAQEAeakOmEmyphLw/P5o/WzEtqrvAa1/
JhcrbhqS4z+3ffCBxr6vz0Corp4ZqRv5mZ4aPQtP65/w/n28lFQm3AphDnmZCvUB3bH21BM1
aHOU3vGPTjuK7Ae/E9m77CbVTqnpOed7Dg2mBgy2PcdWOlqoNweM8AWEb3thsPcCdk1AueqZ
3Mp89KOHzj5wklaDyaA2k+qJdsf9GSdvXvYmoF1g9RgPPVFhwjfmgsixfTYD69E9SNVWP56B
/iQBm3wPeU+C2e8JGbAnjEoS7mOvrloGqjfpsQ7vg8vYmMwd1fu1ImLrYfxMU3wPsnv1hOd+
uGVmBu8Qu8FqH8mmhbYmwiUiUDGCBE0wggRJAgEBMIG0MIGjMQswCQYDVQQGEwJERTEPMA0G
A1UECBMGQmF5ZXJuMREwDwYDVQQHEwhFcmxhbmdlbjEoMCYGA1UEChMfVW5pdmVyc2l0YWV0
IEVybGFuZ2VuLU51ZXJuYmVyZzENMAsGA1UECxMEUlJaRTEPMA0GA1UEAxMGRkFVLUNBMSYw
JAYJKoZIhvcNAQkBFhdjYUBycnplLnVuaS1lcmxhbmdlbi5kZQIMHJRYv4/zxZTgDrzsMA0G
CWCGSAFlAwQCAQUAoIICaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJ
BTEPFw0xNzA4MjkxMDU5MjdaMC8GCSqGSIb3DQEJBDEiBCCZ20Bz/kr6lgg8i8NQ7jFbFq6c
sb8aWfMsX57uuYqeYDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgBZQME
AQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIH
MA0GCCqGSIb3DQMCAgEoMIHFBgkrBgEEAYI3EAQxgbcwgbQwgaMxCzAJBgNVBAYTAkRFMQ8w
DQYDVQQIEwZCYXllcm4xETAPBgNVBAcTCEVybGFuZ2VuMSgwJgYDVQQKEx9Vbml2ZXJzaXRh
ZXQgRXJsYW5nZW4tTnVlcm5iZXJnMQ0wCwYDVQQLEwRSUlpFMQ8wDQYDVQQDEwZGQVUtQ0Ex
JjAkBgkqhkiG9w0BCQEWF2NhQHJyemUudW5pLWVybGFuZ2VuLmRlAgwclFi/j/PFlOAOvOww
gccGCyqGSIb3DQEJEAILMYG3oIG0MIGjMQswCQYDVQQGEwJERTEPMA0GA1UECBMGQmF5ZXJu
MREwDwYDVQQHEwhFcmxhbmdlbjEoMCYGA1UEChMfVW5pdmVyc2l0YWV0IEVybGFuZ2VuLU51
ZXJuYmVyZzENMAsGA1UECxMEUlJaRTEPMA0GA1UEAxMGRkFVLUNBMSYwJAYJKoZIhvcNAQkB
FhdjYUBycnplLnVuaS1lcmxhbmdlbi5kZQIMHJRYv4/zxZTgDrzsMA0GCSqGSIb3DQEBAQUA
BIIBAAGCPqHv/2y8jk5arBSKbjXxDx4VUlLsD6r7xShlsnGegPYk4+2etVZAToIGP/GFFXwu
2UF6ZC/Grt091H8pos9ZHzV88LWrpcWzefDFCGuNLhXxI11wTDUzbuImGWP0x6snnWY+smUv
Vdh6mvEEl+tBUpbtSQjZzoV3USfTlNUHfDSZ2N//rq9vUtXNzEMoUBseLlkJLIW9dVxJ1vXL
33ijRIAm1h+PkmapU2F1yz7Pt5bf2xhQgIZlsLgA7+cF5qyjsvoUob+GgEwNqwDA/4Y0UAYl
G9T7hfQhUMq1ptE2xeh+Il3rSBXXjvSwxxqFkNSFaxWRNLQ3ggZ6vXv5G5gAAAAAAAA=
--------------ms070509090600040403040709--
