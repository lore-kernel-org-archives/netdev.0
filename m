From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.11 6/8] tg3: Fix jumbo frames phy settings
Date: Mon, 21 Mar 2005 00:02:02 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3E26@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="----_=_NextPart_001_01C52DEC.440131E7"
Cc: netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C52DEC.440131E7
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Fix jumbo frame settings on all copper phys that support jumbo frames by
setting the fifo elasticity bit. This setting is for the phy's tx fifo =
to
properly handle jumbo frames. Note that a similar jumbo frame fix for =
the
phy's rx fifo was made to tg3 in the past.

Signed-off-by: Michael Chan <mchan@broadcom.com>

------_=_NextPart_001_01C52DEC.440131E7
Content-Type: application/octet-stream;
 name=tg3-6.patch
Content-Transfer-Encoding: base64
Content-Description: tg3-6.patch
Content-Disposition: attachment;
 filename=tg3-6.patch

ZGlmZiAtTnJ1IDYvZHJpdmVycy9uZXQvdGczLmMgNy9kcml2ZXJzL25ldC90ZzMuYwotLS0gNi9k
cml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE3IDE4OjUxOjM4LjAwMDAwMDAwMCAtMDgwMAorKysg
Ny9kcml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE4IDE2OjQxOjU5LjAwMDAwMDAwMCAtMDgwMApA
QCAtODY4LDYgKzg2OCwxOSBAQAogCQkgICAgIXRnM19yZWFkcGh5KHRwLCBNSUlfVEczX0FVWF9D
VFJMLCAmcGh5X3JlZykpCiAJCQl0ZzNfd3JpdGVwaHkodHAsIE1JSV9URzNfQVVYX0NUUkwsIHBo
eV9yZWcgfCAweDQwMDApOwogCX0KKworCS8qIFNldCBwaHkgcmVnaXN0ZXIgMHgxMCBiaXQgMCB0
byBoaWdoIGZpZm8gZWxhc3RpY2l0eSB0byBzdXBwb3J0CisJICoganVtYm8gZnJhbWVzIHRyYW5z
bWlzc2lvbi4KKwkgKi8KKwlpZiAoR0VUX0FTSUNfUkVWKHRwLT5wY2lfY2hpcF9yZXZfaWQpICE9
IEFTSUNfUkVWXzU3MDUgJiYKKwkgICAgR0VUX0FTSUNfUkVWKHRwLT5wY2lfY2hpcF9yZXZfaWQp
ICE9IEFTSUNfUkVWXzU3NTApIHsKKwkJdTMyIHBoeV9yZWc7CisKKwkJaWYgKCF0ZzNfcmVhZHBo
eSh0cCwgTUlJX1RHM19FWFRfQ1RSTCwgJnBoeV9yZWcpKQorCQkgICAgdGczX3dyaXRlcGh5KHRw
LCBNSUlfVEczX0VYVF9DVFJMLAorCQkJCSBwaHlfcmVnIHwgTUlJX1RHM19FWFRfQ1RSTF9GSUZP
X0VMQVNUSUMpOworCX0KKwogCXRnM19waHlfc2V0X3dpcmVzcGVlZCh0cCk7CiAJcmV0dXJuIDA7
CiB9CmRpZmYgLU5ydSA2L2RyaXZlcnMvbmV0L3RnMy5oIDcvZHJpdmVycy9uZXQvdGczLmgKLS0t
IDYvZHJpdmVycy9uZXQvdGczLmgJMjAwNS0wMy0xNyAxODo1MTo0Mi4wMDAwMDAwMDAgLTA4MDAK
KysrIDcvZHJpdmVycy9uZXQvdGczLmgJMjAwNS0wMy0xOCAxNjo0MjowMy4wMDAwMDAwMDAgLTA4
MDAKQEAgLTE1MTgsNiArMTUxOCw3IEBACiAjZGVmaW5lICBNSUlfVEczX0NUUkxfRU5BQkxFX0FT
X01BU1RFUgkweDEwMDAKIAogI2RlZmluZSBNSUlfVEczX0VYVF9DVFJMCQkweDEwIC8qIEV4dGVu
ZGVkIGNvbnRyb2wgcmVnaXN0ZXIgKi8KKyNkZWZpbmUgIE1JSV9URzNfRVhUX0NUUkxfRklGT19F
TEFTVElDCTB4MDAwMQogI2RlZmluZSAgTUlJX1RHM19FWFRfQ1RSTF9MTkszX0xFRF9NT0RFCTB4
MDAwMgogI2RlZmluZSAgTUlJX1RHM19FWFRfQ1RSTF9UQkkJCTB4ODAwMAogCg==

------_=_NextPart_001_01C52DEC.440131E7--
