From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.11 2/8] tg3: flush status block in tg3_interrupt
Date: Sun, 20 Mar 2005 23:26:26 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3E22@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="----_=_NextPart_001_01C52DE7.4AAD9CD4"
Cc: netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C52DE7.4AAD9CD4
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Add register read of PCI state register in tg3_interrupt() if status =
block's
updated bit is not set. This will flush the status block and confirm =
whether
the interrupt is ours or not. PCI ordering rules allow the interrupt to
arrive at the CPU ahead of the status block that may be posted at the
chipset.

Signed-off-by: Michael Chan <mchan@broadcom.com>

------_=_NextPart_001_01C52DE7.4AAD9CD4
Content-Type: application/octet-stream;
 name=tg3-2.patch
Content-Transfer-Encoding: base64
Content-Description: tg3-2.patch
Content-Disposition: attachment;
 filename=tg3-2.patch

ZGlmZiAtTnJ1IDIvZHJpdmVycy9uZXQvdGczLmMgMy9kcml2ZXJzL25ldC90ZzMuYwotLS0gMi9k
cml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE0IDIyOjA5OjUxLjAwMDAwMDAwMCAtMDgwMAorKysg
My9kcml2ZXJzL25ldC90ZzMuYwkyMDA1LTAzLTE0IDIyOjI0OjM1LjAwMDAwMDAwMCAtMDgwMApA
QCAtMjg4Niw3ICsyODg2LDEzIEBACiAKIAlzcGluX2xvY2tfaXJxc2F2ZSgmdHAtPmxvY2ssIGZs
YWdzKTsKIAotCWlmIChzYmxrLT5zdGF0dXMgJiBTRF9TVEFUVVNfVVBEQVRFRCkgeworCS8qIElu
IElOVHggbW9kZSwgaXQgaXMgcG9zc2libGUgZm9yIHRoZSBpbnRlcnJ1cHQgdG8gYXJyaXZlIGF0
CisJICogdGhlIENQVSBiZWZvcmUgdGhlIHN0YXR1cyBibG9jayBwb3N0ZWQgcHJpb3IgdG8gdGhl
IGludGVycnVwdC4KKwkgKiBSZWFkaW5nIHRoZSBQQ0kgU3RhdGUgcmVnaXN0ZXIgd2lsbCBjb25m
aXJtIHdoZXRoZXIgdGhlCisJICogaW50ZXJydXB0IGlzIG91cnMgYW5kIHdpbGwgZmx1c2ggdGhl
IHN0YXR1cyBibG9jay4KKwkgKi8KKwlpZiAoKHNibGstPnN0YXR1cyAmIFNEX1NUQVRVU19VUERB
VEVEKSB8fAorCSAgICAhKHRyMzIoVEczUENJX1BDSVNUQVRFKSAmIFBDSVNUQVRFX0lOVF9OT1Rf
QUNUSVZFKSkgewogCQkvKgogCQkgKiB3cml0aW5nIGFueSB2YWx1ZSB0byBpbnRyLW1ib3gtMCBj
bGVhcnMgUENJIElOVEEjIGFuZAogCQkgKiBjaGlwLWludGVybmFsIGludGVycnVwdCBwZW5kaW5n
IGV2ZW50cy4K

------_=_NextPart_001_01C52DE7.4AAD9CD4--
