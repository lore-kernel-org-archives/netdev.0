From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: [except_nonlink net-next]r8169:Add exception when missing link
Date: Sat, 11 Jul 2015 21:32:07 +0300
Message-ID: <CAGg4U=EF+_8qLW_K=ZYtLSjC75RSrVywsMVswua0YpM91GYZog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bdca61ab21dc4051a9db494
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37277 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbbGKScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 14:32:08 -0400
Received: by igpy18 with SMTP id y18so33329363igp.0
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 11:32:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bdca61ab21dc4051a9db494
Content-Type: text/plain; charset=UTF-8

Add exception when missing link because original function "
rtl8169_check_link_status" must be int instead of void.

--047d7bdca61ab21dc4051a9db494
Content-Type: text/x-patch; charset=US-ASCII; name="except_nonlink.patch"
Content-Disposition: attachment; filename="except_nonlink.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ibze2or00

Y29tbWl0IDIxZDI3OTczYjI2NDE5MmE0Y2NkNjQ4OGIxNDg3ZjA3MjkzYjExYzgKQXV0aG9yOiBD
b3Jjb2RlbCBNYXJpYW4gPGFzdUAxOTItMTY4LTAtMy5yZHNuZXQucm8+CkRhdGU6ICAgU2F0IEp1
bCAxMSAyMToxOTo1NyAyMDE1ICswMzAwCgogICAgIENvbW1pdHRlcjogQ29yY29kZWwgTWFyaWFu
IDxhc3VAMTkyLTE2OC0wLTMucmRzbmV0LnJvPgogICAgIEFkZCBleGNlcHRpb24gd2hlbiBub25l
eGlzdGVudCBsaW5rIG9jY3VyIGJlY2F1c2Ugb3JpZyBmdW5jCiAgICAgaXMgdm9pZCBmb3JtYXQg
aW5zdGVhZCBvZiBpbnQuCiAgICAKICAgICBPbiBicmFuY2ggbWFzdGVyCiAgICAgWW91ciBicmFu
Y2ggaXMgYWhlYWQgb2YgJ29yaWdpbi9tYXN0ZXInIGJ5IDEyIGNvbW1pdHMuCiAgICAgICAodXNl
ICJnaXQgcHVzaCIgdG8gcHVibGlzaCB5b3VyIGxvY2FsIGNvbW1pdHMpCiAgICAKICAgICBDaGFu
Z2VzIHRvIGJlIGNvbW1pdHRlZDoKICAgIAltb2RpZmllZDogICBkcml2ZXJzL25ldC9ldGhlcm5l
dC9yZWFsdGVrL3I4MTY5LmMKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFs
dGVrL3I4MTY5LmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZWFsdGVrL3I4MTY5LmMKaW5kZXgg
NDEwYzFlZS4uNzQ2NWVjNCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVhbHRl
ay9yODE2OS5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3JlYWx0ZWsvcjgxNjkuYwpAQCAt
NzY0Myw2ICs3NjQzLDEyIEBAIHN0YXRpYyBpbnQgcnRsX29wZW4oc3RydWN0IG5ldF9kZXZpY2Ug
KmRldikKIAogCXRwLT5zYXZlZF93b2xvcHRzID0gMDsKIAlwbV9ydW50aW1lX3B1dF9ub2lkbGUo
JnBkZXYtPmRldik7CisJaWYgKCF0cC0+bGlua19vayhpb2FkZHIpKSB7CisJCQluZXRpZl9jYXJy
aWVyX29mZihkZXYpOworCQluZXRpZl9pbmZvKHRwLCBpZmRvd24sIGRldiwgImxpbmsgZG93blxu
Iik7CisJCXBtX3NjaGVkdWxlX3N1c3BlbmQoJnRwLT5wY2lfZGV2LT5kZXYsIDIwMCk7CisJICBn
b3RvIG91dDsgCisJfQogCiAJcnRsODE2OV9jaGVja19saW5rX3N0YXR1cyhkZXYsIHRwLCBpb2Fk
ZHIpOwogb3V0Ogo=
--047d7bdca61ab21dc4051a9db494--
