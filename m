From: Jack Ma <Jack.Ma@alliedtelesis.co.nz>
Subject: Adding support for VRF traffic passed by mangle table
Date: Mon, 3 Apr 2017 02:57:46 +0000
Message-ID: <1491188266363.26046@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_149118826636326046alliedtelesisconz_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:36405 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdDCC5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 22:57:53 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 6E15087822
        for <netdev@vger.kernel.org>; Mon,  3 Apr 2017 14:57:50 +1200 (NZST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_149118826636326046alliedtelesisconz_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

SGkgRGF2aWQsCgpJIGZvcm1hdHRlZCBhIHBhdGNoIHRvIHN1cHBvcnQgdnJmIGZsb3cgcGFzc2Vk
IGJ5IGlwdGFibGVzKG1hbmdsZSB0YWJsZSkuIEFuZCBwcmV2aW91c2x5LCB3ZSBsb3N0IHRoZSBm
bG93Lm9pZiB3aGljaCB3b3VsZCByZXN1bHQgaW4gYSByb3V0aW5nIGxvb2stdXAgZmFpbHVyZS4g
VGhpcyBwYXRjaCB3cmFwcyB2cmYgcmVzcG9uc2UgZmxvdyB3aXRoIHRoZSBjb3JyZWN0IG1hc3Rl
ciBpbnRlcmZhY2UgYnkgdXNpbmcgdGhlIHNrYi0+ZGV2LCB3aGljaCB3YXMgc2V0IHRvIHRoZSBy
ZWFsIGluZ3Jlc3MgZGV2aWNlLgpXaXRob3V0IHRoaXMgcGF0Y2gsIFZSRiB0cmFmZmljIHBlcm1p
dHRlZCBieSBmaXJld2FsbCBydWxlcyB0aGF0IGNoYW5nZXMgbmZfbWFyayB3b3VsZCBiZSBkcm9w
cGVkIHdoaWxlIGRvaW5nIGZpYl9sb29rdXAuCktlcm5lbCBkb2N1bWVudGF0aW9ucyBzdWdnZXN0
ZWQgdHdvIHdheSBvZiBmaXhpbmcgdGhpczoKCiAKICAgICAgICA8CiAgICAgICAgWzJdIElwdGFi
bGVzIG9uIGluZ3Jlc3Mgc3VwcG9ydHMgUFJFUk9VVElORyB3aXRoIHNrYi0+ZGV2IHNldCB0byB0
aGUgcmVhbAogICAgICAgICAgICBpbmdyZXNzIGRldmljZSBhbmQgYm90aCBJTlBVVCBhbmQgUFJF
Uk9VVElORyBydWxlcyB3aXRoIHNrYi0+ZGV2IHNldCB0bwogICAgICAgICAgICB0aGUgVlJGIGRl
dmljZS4gRm9yIGVncmVzcyBQT1NUUk9VVElORyBhbmQgT1VUUFVUIHJ1bGVzIGNhbiBiZSB3cml0
dGVuCiAgICAgICAgICAgIHVzaW5nIGVpdGhlciB0aGUgVlJGIGRldmljZSBvciByZWFsIGVncmVz
cyBkZXZpY2UuCiAgICAgICAgPgoKCkNvdWxkIHlvdSBwbGVhc2UgbG9vayBhdCB0aGlzIHBhdGNo
IGFuZCBnaXZlIG1lIHNvbWUgZmVlZGJhY2s/ClRoYW5rcyBmb3IgeW91ciB0aW1lIGFuZCBjb25z
aWRlcmF0aW9ucy4K4oCLClJlZ2FyZHMsCkphY2sKCgoKCmRpZmYgLS1naXQgYS9uZXQvaXB2NC9u
ZXRmaWx0ZXIuYyBiL25ldC9pcHY0L25ldGZpbHRlci5jCmluZGV4IGMwY2M2YWEuLjA3MTY4ZDQg
MTAwNjQ0Ci0tLSBhL25ldC9pcHY0L25ldGZpbHRlci5jCisrKyBiL25ldC9pcHY0L25ldGZpbHRl
ci5jCkBAIC00Niw2ICs0NiwxNCBAQCBpbnQgaXBfcm91dGVfbWVfaGFyZGVyKHN0cnVjdCBuZXQg
Km5ldCwgc3RydWN0IHNrX2J1ZmYgKnNrYiwgdW5zaWduZWQgaW50IGFkZHJfdAogICAgICAgICAg
ICAgICAgZmw0LmZsb3dpNF9vaWYgPSBsM21kZXZfbWFzdGVyX2lmaW5kZXgoZGV2KTsKICAgICAg
ICBmbDQuZmxvd2k0X21hcmsgPSBza2ItPm1hcms7CiAgICAgICAgZmw0LmZsb3dpNF9mbGFncyA9
IGZsYWdzOworCisgICAgICAgLyogU2luY2Ugd2UgaGF2ZSBhbHJlYWR5IGtub3duIHRoaXMgaXMg
dnJmIGZsb3cgcGFzc2VkIGJ5CisgICAgICAgICogbWFuZ2xlIHRhYmxlLCB3ZSB3cmFwIHRoZSBv
aWYgd2l0aCB0aGUgbWFzdGVyIGludGVyZmFjZS4KKyAgICAgICAgKi8KKyAgICAgICBpZiAoZmw0
LmZsb3dpNF9vaWYgPT0gMCAmJiBmbDQuZGFkZHIgJiYgc2tiLT5kZXYgJiYKKyAgICAgICAgICAg
bmV0aWZfaW5kZXhfaXNfbDNfbWFzdGVyKG5ldCwgc2tiLT5kZXYtPmlmaW5kZXgpKQorICAgICAg
ICAgICAgICAgZmw0LmZsb3dpNF9vaWYgPSBza2ItPmRldi0+aWZpbmRleDsKKwogICAgICAgIHJ0
ID0gaXBfcm91dGVfb3V0cHV0X2tleShuZXQsICZmbDQpOwogICAgICAgIGlmIChJU19FUlIocnQp
KQogICAgICAgICAgICAgICAgcmV0dXJuIFBUUl9FUlIocnQpOw==

--_002_149118826636326046alliedtelesisconz_
Content-Type: text/x-patch; name="VRF_support.patch"
Content-Description: VRF_support.patch
Content-Disposition: attachment; filename="VRF_support.patch"; size=64;
	creation-date="Mon, 03 Apr 2017 02:57:43 GMT";
	modification-date="Mon, 03 Apr 2017 02:57:43 GMT"
Content-Transfer-Encoding: base64

MDAwMS1XcmFwLXZyZi10cmFmZmljLXBhc3NlZC1ieS1tYW5nbGUtdGFibGUtd2l0aC1jb3JyZWN0
LnBhdGNoCg==

--_002_149118826636326046alliedtelesisconz_--
