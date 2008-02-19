From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [NETLABEL] Minor cleanup: remove unused method definition
Date: Tue, 19 Feb 2008 16:25:31 +0200
Message-ID: <eb3ff54b0802190625v5315aac9m7ffd580b30bce8cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5887_6209634.1203431132083"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17320 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbYBSOZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:25:34 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1888763fga.17
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 06:25:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5887_6209634.1203431132083
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

This patch removes definition of netlbl_cfg_cipsov4_del() method in
netlabel/netlabel_kapi.c and in include/net/netlabel.h as it is not used.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5887_6209634.1203431132083
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fcujs72o0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25ldGxhYmVsLmggYi9pbmNsdWRlL25ldC9uZXRsYWJl
bC5oCmluZGV4IDBjYTY3ZDcuLjkxMWQ4YzYgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L25ldGxh
YmVsLmgKKysrIGIvaW5jbHVkZS9uZXQvbmV0bGFiZWwuaApAQCAtMzUwLDcgKzM1MCw2IEBAIGlu
dCBuZXRsYmxfY2ZnX2NpcHNvdjRfYWRkKHN0cnVjdCBjaXBzb192NF9kb2kgKmRvaV9kZWYsCiBp
bnQgbmV0bGJsX2NmZ19jaXBzb3Y0X2FkZF9tYXAoc3RydWN0IGNpcHNvX3Y0X2RvaSAqZG9pX2Rl
ZiwKIAkJCSAgICAgICBjb25zdCBjaGFyICpkb21haW4sCiAJCQkgICAgICAgc3RydWN0IG5ldGxi
bF9hdWRpdCAqYXVkaXRfaW5mbyk7Ci1pbnQgbmV0bGJsX2NmZ19jaXBzb3Y0X2RlbCh1MzIgZG9p
LCBzdHJ1Y3QgbmV0bGJsX2F1ZGl0ICphdWRpdF9pbmZvKTsKIAogLyoKICAqIExTTSBzZWN1cml0
eSBhdHRyaWJ1dGUgb3BlcmF0aW9ucwpAQCAtNDA4LDExICs0MDcsNiBAQCBzdGF0aWMgaW5saW5l
IGludCBuZXRsYmxfY2ZnX2NpcHNvdjRfYWRkX21hcChzdHJ1Y3QgY2lwc29fdjRfZG9pICpkb2lf
ZGVmLAogewogCXJldHVybiAtRU5PU1lTOwogfQotc3RhdGljIGlubGluZSBpbnQgbmV0bGJsX2Nm
Z19jaXBzb3Y0X2RlbCh1MzIgZG9pLAotCQkJCQkgc3RydWN0IG5ldGxibF9hdWRpdCAqYXVkaXRf
aW5mbykKLXsKLQlyZXR1cm4gLUVOT1NZUzsKLX0KIHN0YXRpYyBpbmxpbmUgaW50IG5ldGxibF9z
ZWNhdHRyX2NhdG1hcF93YWxrKAogCSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHN0cnVj
dCBuZXRsYmxfbHNtX3NlY2F0dHJfY2F0bWFwICpjYXRtYXAsCiAJCQkJICAgICAgdTMyIG9mZnNl
dCkKZGlmZiAtLWdpdCBhL25ldC9uZXRsYWJlbC9uZXRsYWJlbF9rYXBpLmMgYi9uZXQvbmV0bGFi
ZWwvbmV0bGFiZWxfa2FwaS5jCmluZGV4IDM5NzkzYTEuLjAyYjI2OGQgMTAwNjQ0Ci0tLSBhL25l
dC9uZXRsYWJlbC9uZXRsYWJlbF9rYXBpLmMKKysrIGIvbmV0L25ldGxhYmVsL25ldGxhYmVsX2th
cGkuYwpAQCAtMjAzLDIxICsyMDMsNiBAQCBjZmdfY2lwc292NF9hZGRfbWFwX2ZhaWx1cmU6CiAJ
cmV0dXJuIHJldF92YWw7CiB9CiAKLS8qKgotICogbmV0bGJsX2NmZ19jaXBzb3Y0X2RlbCAtIFJl
bW92ZWFuIGV4aXN0aW5nIENJUFNPdjQgRE9JIGRlZmluaXRpb24KLSAqIEBkb2k6IHRoZSBDSVBT
TyBET0kgdmFsdWUKLSAqIEBhdWRpdF9pbmZvOiBOZXRMYWJlbCBhdWRpdCBpbmZvcm1hdGlvbgot
ICoKLSAqIERlc2NyaXB0aW9uOgotICogUmVtb3ZlcyBhbiBleGlzdGluZyBDSVBTT3Y0IERPSSBk
ZWZpbml0aW9uIGZyb20gdGhlIE5ldExhYmVsIHN1YnN5c3RlbS4KLSAqIFJldHVybnMgemVybyBv
biBzdWNjZXNzLCBuZWdhdGl2ZSB2YWx1ZXMgb24gZmFpbHVyZS4KLSAqCi0gKi8KLWludCBuZXRs
YmxfY2ZnX2NpcHNvdjRfZGVsKHUzMiBkb2ksIHN0cnVjdCBuZXRsYmxfYXVkaXQgKmF1ZGl0X2lu
Zm8pCi17Ci0JcmV0dXJuIGNpcHNvX3Y0X2RvaV9yZW1vdmUoZG9pLCBhdWRpdF9pbmZvLCBuZXRs
YmxfY2lwc292NF9kb2lfZnJlZSk7Ci19Ci0KIC8qCiAgKiBTZWN1cml0eSBBdHRyaWJ1dGUgRnVu
Y3Rpb25zCiAgKi8K
------=_Part_5887_6209634.1203431132083--
