From: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Subject: [PATCH] usbnet: dereference after null check in usbnet_start_xmit()
 and __usbnet_read_cmd()
Date: Wed, 19 Aug 2015 11:21:35 +0000 (GMT)
Message-ID: <907196681.281711439983295252.JavaMail.weblogic@ep2mlwas02b>
Reply-To: vivek.bhagat@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: nitin.j@samsung.com, hemanshu.s@samsung.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:44484 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbbHSLVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 07:21:36 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NTB02S0KU7ZIOE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 19 Aug 2015 20:21:35 +0900 (KST)
MIME-version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dXNibmV0X3N0YXJ0X3htaXQoKSAtIElmIGluZm8tPnR4X2ZpeHVwIGlzIG5vdCBkZWZpbmVkIGJ5
IGNsYXNzIGRyaXZlciwKTlVMTCBjaGVjayBkb2VzIG5vdCBoYXBwZW4gZm9yIHNrYiBwb2ludGVy
IGFuZCBsZWFkcyB0byBOVUxMIGRlcmVmZXJlbmNlLgpfX3VzYm5ldF9yZWFkX2NtZCgpIC0gaWYg
ZGF0YSBwb2ludGVyIGlzIHBhc3NlZCBhcyBOVUxMLCBtZW1jcHkgd2lsbApkZXJlZmVyZW5jZSBO
VUxMIHBvaW50ZXIuCgpTaWduZWQtb2ZmLWJ5OiBWaXZlayBLdW1hciBCaGFnYXQgPHZpdmVrLmJo
YWdhdEBzYW1zdW5nLmNvbT4KLS0tCiBkcml2ZXJzL25ldC91c2IvdXNibmV0LmMgfCAgICA1ICsr
KystCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZm
IC0tZ2l0IGEvZHJpdmVycy9uZXQvdXNiL3VzYm5ldC5jIGIvZHJpdmVycy9uZXQvdXNiL3VzYm5l
dC5jCmluZGV4IDNjODZiMTAuLmVjNGQyMjQgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VzYi91
c2JuZXQuYworKysgYi9kcml2ZXJzL25ldC91c2IvdXNibmV0LmMKQEAgLTEyOTQsNiArMTI5NCw4
IEBAIG5ldGRldl90eF90IHVzYm5ldF9zdGFydF94bWl0IChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAog
CiAJaWYgKHNrYikKIAkJc2tiX3R4X3RpbWVzdGFtcChza2IpOworCWVsc2UKKwkJZ290byBkcm9w
OwogCiAJLy8gc29tZSBkZXZpY2VzIHdhbnQgZnVua3kgVVNCLWxldmVsIGZyYW1pbmcsIGZvcgog
CS8vIHdpbjMyIGRyaXZlciAodXN1YWxseSkgYW5kL29yIGhhcmR3YXJlIHF1aXJrcwpAQCAtMTkw
Niw3ICsxOTA4LDggQEAgc3RhdGljIGludCBfX3VzYm5ldF9yZWFkX2NtZChzdHJ1Y3QgdXNibmV0
ICpkZXYsIHU4IGNtZCwgdTggcmVxdHlwZSwKIAkJYnVmID0ga21hbGxvYyhzaXplLCBHRlBfS0VS
TkVMKTsKIAkJaWYgKCFidWYpCiAJCQlnb3RvIG91dDsKLQl9CisJfSBlbHNlCisJCWdvdG8gb3V0
OwogCiAJZXJyID0gdXNiX2NvbnRyb2xfbXNnKGRldi0+dWRldiwgdXNiX3JjdmN0cmxwaXBlKGRl
di0+dWRldiwgMCksCiAJCQkgICAgICBjbWQsIHJlcXR5cGUsIHZhbHVlLCBpbmRleCwgYnVmLCBz
aXplLAotLSAKMS43LjkuNQ==
