From: "Ed Swierk" <eswierk@arastra.com>
Subject: [PATCH] Configurable tap interface MTU
Date: Tue, 11 Sep 2007 07:42:46 -0700
Message-ID: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6287_13624360.1189521766884"
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:8146 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbXIKOmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 10:42:47 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1326391rvb
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 07:42:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_6287_13624360.1189521766884
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch makes it possible to change the MTU on a tap interface.
Increasing the MTU beyond the 1500-byte default is useful for
applications that interoperate with Ethernet devices supporting jumbo
frames.

The patch caps the MTU somewhat arbitrarily at 16000 bytes. This is
slightly lower than the value used by the e1000 driver, so it seems
like a safe upper limit.

Signed-off-by: Ed Swierk <eswierk@arastra.com>

---

------=_Part_6287_13624360.1189521766884
Content-Type: application/octet-stream; name="tap-change-mtu.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="tap-change-mtu.patch"
X-Attachment-Id: f_f6giijh1

SW5kZXg6IGxpbnV4LTIuNi4yMi42L2RyaXZlcnMvbmV0L3R1bi5jCj09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxp
bnV4LTIuNi4yMi42Lm9yaWcvZHJpdmVycy9uZXQvdHVuLmMKKysrIGxpbnV4LTIuNi4yMi42L2Ry
aXZlcnMvbmV0L3R1bi5jCkBAIC0xNzEsNiArMTcxLDE4IEBAIHR1bl9uZXRfbWNsaXN0KHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYpCiAJfQogfQogCisjZGVmaW5lIE1JTl9NVFUgNjgKKyNkZWZpbmUg
TUFYX01UVSAxNjAwMAorCitzdGF0aWMgaW50Cit0dW5fbmV0X2NoYW5nZV9tdHUoc3RydWN0IG5l
dF9kZXZpY2UgKmRldiwgaW50IG5ld19tdHUpCit7CisJaWYgKG5ld19tdHUgPCBNSU5fTVRVIHx8
IG5ld19tdHUgPiBNQVhfTVRVKQorCQlyZXR1cm4gLUVJTlZBTDsKKwlkZXYtPm10dSA9IG5ld19t
dHU7CisJcmV0dXJuIDA7Cit9CisKIHN0YXRpYyBzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyAqdHVu
X25ldF9zdGF0cyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewogCXN0cnVjdCB0dW5fc3RydWN0
ICp0dW4gPSBuZXRkZXZfcHJpdihkZXYpOwpAQCAtMjAwLDYgKzIxMiw3IEBAIHN0YXRpYyB2b2lk
IHR1bl9uZXRfaW5pdChzdHJ1Y3QgbmV0X2RldmkKIAkJZGV2LT5zZXRfbXVsdGljYXN0X2xpc3Qg
PSB0dW5fbmV0X21jbGlzdDsKIAogCQlldGhlcl9zZXR1cChkZXYpOworCQlkZXYtPmNoYW5nZV9t
dHUgPSB0dW5fbmV0X2NoYW5nZV9tdHU7CiAKIAkJLyogcmFuZG9tIGFkZHJlc3MgYWxyZWFkeSBj
cmVhdGVkIGZvciB1cyBieSB0dW5fc2V0X2lmZiwgdXNlIGl0ICovCiAJCW1lbWNweShkZXYtPmRl
dl9hZGRyLCB0dW4tPmRldl9hZGRyLCBtaW4oc2l6ZW9mKHR1bi0+ZGV2X2FkZHIpLCBzaXplb2Yo
ZGV2LT5kZXZfYWRkcikpICk7Cg==
------=_Part_6287_13624360.1189521766884--
