From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.11 5/8] tg3: Add unstable PLL workaround for 5750
Date: Sun, 20 Mar 2005 23:48:13 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3E25@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="----_=_NextPart_001_01C52DEA.55A920F9"
Cc: netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C52DEA.55A920F9
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Add unstable PLL clock workaround for 5750 Ax and Bx devices. The =
workaround
code is run just before entering D3hot state.

Signed-off-by: Michael Chan <mchan@broadcom.com>

------_=_NextPart_001_01C52DEA.55A920F9
Content-Type: application/octet-stream;
 name=tg3-5.patch
Content-Transfer-Encoding: base64
Content-Description: tg3-5.patch
Content-Disposition: attachment;
 filename=tg3-5.patch

ZGlmZiAtTnJ1IDUvZHJpdmVycy9uZXQvdGczLmMgNi9kcml2ZXJzL25ldC90ZzMuYwotLS0gNS9k
cml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE3IDE3OjE1OjQwLjAwMDAwMDAwMCAtMDgwMAorKysg
Ni9kcml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE3IDE4OjUxOjM4LjAwMDAwMDAwMCAtMDgwMApA
QCAtOTY2LDYgKzk2Niw3IEBACiAjZGVmaW5lIFJFU0VUX0tJTkRfU1VTUEVORAkyCiAKIHN0YXRp
YyB2b2lkIHRnM193cml0ZV9zaWdfcG9zdF9yZXNldChzdHJ1Y3QgdGczICosIGludCk7CitzdGF0
aWMgaW50IHRnM19oYWx0X2NwdShzdHJ1Y3QgdGczICosIHUzMik7CiAKIHN0YXRpYyBpbnQgdGcz
X3NldF9wb3dlcl9zdGF0ZShzdHJ1Y3QgdGczICp0cCwgaW50IHN0YXRlKQogewpAQCAtMTEyNCw2
ICsxMTI1LDE3IEBACiAKIAl0ZzNfZnJvYl9hdXhfcG93ZXIodHApOwogCisJLyogV29ya2Fyb3Vu
ZCBmb3IgdW5zdGFibGUgUExMIGNsb2NrICovCisJaWYgKChHRVRfQ0hJUF9SRVYodHAtPnBjaV9j
aGlwX3Jldl9pZCkgPT0gQ0hJUFJFVl81NzUwX0FYKSB8fAorCSAgICAoR0VUX0NISVBfUkVWKHRw
LT5wY2lfY2hpcF9yZXZfaWQpID09IENISVBSRVZfNTc1MF9CWCkpIHsKKwkJdTMyIHZhbCA9IHRy
MzIoMHg3ZDAwKTsKKworCQl2YWwgJj0gfigoMSA8PCAxNikgfCAoMSA8PCA0KSB8ICgxIDw8IDIp
IHwgKDEgPDwgMSkgfCAxKTsKKwkJdHczMigweDdkMDAsIHZhbCk7CisJCWlmICghKHRwLT50ZzNf
ZmxhZ3MgJiBURzNfRkxBR19FTkFCTEVfQVNGKSkKKwkJCXRnM19oYWx0X2NwdSh0cCwgUlhfQ1BV
X0JBU0UpOworCX0KKwogCS8qIEZpbmFsbHksIHNldCB0aGUgbmV3IHBvd2VyIHN0YXRlLiAqLwog
CXBjaV93cml0ZV9jb25maWdfd29yZCh0cC0+cGRldiwgcG0gKyBQQ0lfUE1fQ1RSTCwgcG93ZXJf
Y29udHJvbCk7CiAK

------_=_NextPart_001_01C52DEA.55A920F9--
