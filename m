From: Raimonds Cicans <ray@apollo.lv>
Subject: r8169: fix driver drop incoming packets >= 1515 if MTU is set between
 1515 and 1536
Date: Wed, 11 Nov 2009 20:20:17 +0200
Message-ID: <4AFB0061.7020908@apollo.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060703070803090901000909"
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.apollo.lv ([80.232.168.197]:39114 "EHLO smtp5.apollo.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758294AbZKKSUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 13:20:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060703070803090901000909
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


--------------060703070803090901000909
Content-Type: text/plain;
 name="r8169-mtu1536.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="r8169-mtu1536.patch"

RHJpdmVyIGRyb3AgaW5jb21pbmcgcGFja2V0cyA+PSAxNTE1KDEpIGlmIE1UVSBpcyBzZXQg
YmV0d2VlbiAxNTE1KDEpIGFuZCAxNTM2LgoKMSkgZXhhY3QgbnVtYmVyIGRlcGVuZHMgb24g
c29tZSBmYWN0b3JzOgotIFZMQU4gdGFnZ2VkIG9yIG5vdAotIHBhdGNoICJyODE2OTogRml4
IGNhcmQgZHJvcCBpbmNvbWluZyBWTEFOIHRhZ2dlZCBNVFUgYnl0ZSBsYXJnZSBqdW1ibyBm
cmFtZXMiCiAgYXBwbGllZCBvciBub3QKCkJvbnVzOiBnb3QgcmlkIG9mIG1hZ2ljIG51bWJl
ciA4CgpTaWduZWQtb2ZmLWJ5OiBSYWltb25kcyBDaWNhbnMgPHJheUBhcG9sbG8ubHY+Cgot
LS0KCi0tLSBsaW51eC0yLjYuMzEvZHJpdmVycy9uZXQvcjgxNjkuYy5vcmlnCTIwMDktMTEt
MDYgMjE6NTI6MTIuNzIyMzI2NjAxICswMjAwCisrKyBsaW51eC0yLjYuMzEvZHJpdmVycy9u
ZXQvcjgxNjkuYwkyMDA5LTExLTA2IDIyOjA5OjE3LjI0MjIyNDAxNCArMDIwMApAQCAtMjIy
OSw5ICsyMjI5LDkgQEAgc3RhdGljIHZvaWQgX19kZXZleGl0IHJ0bDgxNjlfcmVtb3ZlX29u
ZQogc3RhdGljIHZvaWQgcnRsODE2OV9zZXRfcnhidWZzaXplKHN0cnVjdCBydGw4MTY5X3By
aXZhdGUgKnRwLAogCQkJCSAgc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKLQl1bnNpZ25l
ZCBpbnQgbXR1ID0gZGV2LT5tdHU7CisJdW5zaWduZWQgaW50IG1heF9mcmFtZSA9IGRldi0+
bXR1ICsgVkxBTl9FVEhfSExFTiArIEVUSF9GQ1NfTEVOOwogCi0JdHAtPnJ4X2J1Zl9zeiA9
IChtdHUgPiBSWF9CVUZfU0laRSkgPyBtdHUgKyBFVEhfSExFTiArIDggOiBSWF9CVUZfU0la
RTsKKwl0cC0+cnhfYnVmX3N6ID0gKG1heF9mcmFtZSA+IFJYX0JVRl9TSVpFKSA/IG1heF9m
cmFtZSA6IFJYX0JVRl9TSVpFOwogfQogCiBzdGF0aWMgaW50IHJ0bDgxNjlfb3BlbihzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2KQo=
--------------060703070803090901000909--
