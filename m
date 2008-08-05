From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 1/2] ipv4: replace dst_metric() with dst_mtu() in net/ipv4/route.c.
Date: Tue, 5 Aug 2008 16:00:21 +0300
Message-ID: <eb3ff54b0808050600s1b49d7dp8d6b8db8cc9203c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5690_18633498.1217941221269"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:55434 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033AbYHENAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 09:00:21 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4047581wfd.4
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 06:00:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5690_18633498.1217941221269
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch replaces dst_metric() with dst_mtu() in net/ipv4/route.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5690_18633498.1217941221269
Content-Type: text/x-patch; name=0010-replace-dst_metric-with-dst_mtu.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fjiipstm0
Content-Disposition: attachment;
 filename=0010-replace-dst_metric-with-dst_mtu.patch

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3JvdXRlLmMgYi9uZXQvaXB2NC9yb3V0ZS5jCmluZGV4IDFi
ZmEwNzguLmVjY2I2MTggMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3JvdXRlLmMKKysrIGIvbmV0L2lw
djQvcm91dGUuYwpAQCAtMTUwOSwxNCArMTUwOSwxNCBAQCB1bnNpZ25lZCBzaG9ydCBpcF9ydF9m
cmFnX25lZWRlZChzdHJ1Y3QgbmV0ICpuZXQsIHN0cnVjdCBpcGhkciAqaXBoLAogCiAJCQkJCS8q
IEJTRCA0LjIgY29tcGF0aWJpbGl0eSBoYWNrIDotKCAqLwogCQkJCQlpZiAobXR1ID09IDAgJiYK
LQkJCQkJICAgIG9sZF9tdHUgPj0gZHN0X21ldHJpYygmcnRoLT51LmRzdCwgUlRBWF9NVFUpICYm
CisJCQkJCSAgICBvbGRfbXR1ID49IGRzdF9tdHUoJnJ0aC0+dS5kc3QpICYmCiAJCQkJCSAgICBv
bGRfbXR1ID49IDY4ICsgKGlwaC0+aWhsIDw8IDIpKQogCQkJCQkJb2xkX210dSAtPSBpcGgtPmlo
bCA8PCAyOwogCiAJCQkJCW10dSA9IGd1ZXNzX210dShvbGRfbXR1KTsKIAkJCQl9Ci0JCQkJaWYg
KG10dSA8PSBkc3RfbWV0cmljKCZydGgtPnUuZHN0LCBSVEFYX01UVSkpIHsKLQkJCQkJaWYgKG10
dSA8IGRzdF9tZXRyaWMoJnJ0aC0+dS5kc3QsIFJUQVhfTVRVKSkgeworCQkJCWlmIChtdHUgPD0g
ZHN0X210dSgmcnRoLT51LmRzdCkpIHsKKwkJCQkJaWYgKG10dSA8IGRzdF9tdHUoJnJ0aC0+dS5k
c3QpKSB7CiAJCQkJCQlkc3RfY29uZmlybSgmcnRoLT51LmRzdCk7CiAJCQkJCQlpZiAobXR1IDwg
aXBfcnRfbWluX3BtdHUpIHsKIAkJCQkJCQltdHUgPSBpcF9ydF9taW5fcG10dTsKQEAgLTE1Mzgs
NyArMTUzOCw3IEBAIHVuc2lnbmVkIHNob3J0IGlwX3J0X2ZyYWdfbmVlZGVkKHN0cnVjdCBuZXQg
Km5ldCwgc3RydWN0IGlwaGRyICppcGgsCiAKIHN0YXRpYyB2b2lkIGlwX3J0X3VwZGF0ZV9wbXR1
KHN0cnVjdCBkc3RfZW50cnkgKmRzdCwgdTMyIG10dSkKIHsKLQlpZiAoZHN0X21ldHJpYyhkc3Qs
IFJUQVhfTVRVKSA+IG10dSAmJiBtdHUgPj0gNjggJiYKKwlpZiAoZHN0X210dShkc3QpID4gbXR1
ICYmIG10dSA+PSA2OCAmJgogCSAgICAhKGRzdF9tZXRyaWNfbG9ja2VkKGRzdCwgUlRBWF9NVFUp
KSkgewogCQlpZiAobXR1IDwgaXBfcnRfbWluX3BtdHUpIHsKIAkJCW10dSA9IGlwX3J0X21pbl9w
bXR1OwpAQCAtMTY2Nyw3ICsxNjY3LDcgQEAgc3RhdGljIHZvaWQgcnRfc2V0X25leHRob3Aoc3Ry
dWN0IHJ0YWJsZSAqcnQsIHN0cnVjdCBmaWJfcmVzdWx0ICpyZXMsIHUzMiBpdGFnKQogCiAJaWYg
KGRzdF9tZXRyaWMoJnJ0LT51LmRzdCwgUlRBWF9IT1BMSU1JVCkgPT0gMCkKIAkJcnQtPnUuZHN0
Lm1ldHJpY3NbUlRBWF9IT1BMSU1JVC0xXSA9IHN5c2N0bF9pcF9kZWZhdWx0X3R0bDsKLQlpZiAo
ZHN0X21ldHJpYygmcnQtPnUuZHN0LCBSVEFYX01UVSkgPiBJUF9NQVhfTVRVKQorCWlmIChkc3Rf
bXR1KCZydC0+dS5kc3QpID4gSVBfTUFYX01UVSkKIAkJcnQtPnUuZHN0Lm1ldHJpY3NbUlRBWF9N
VFUtMV0gPSBJUF9NQVhfTVRVOwogCWlmIChkc3RfbWV0cmljKCZydC0+dS5kc3QsIFJUQVhfQURW
TVNTKSA9PSAwKQogCQlydC0+dS5kc3QubWV0cmljc1tSVEFYX0FEVk1TUy0xXSA9IG1heF90KHVu
c2lnbmVkIGludCwgcnQtPnUuZHN0LmRldi0+bXR1IC0gNDAsCgo=
------=_Part_5690_18633498.1217941221269--
