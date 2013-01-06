From: Arjan van de Ven <arjanvandeven@gmail.com>
Subject: small iputils build patch
Date: Sun, 6 Jan 2013 08:42:03 -0800
Message-ID: <CADyApD2CxE=mEWKCF9gW=0vGgFkcZZo=DRi-UKP8wNeXMXUifQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d0434bf1e6d88f004d2a16439
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:60617 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab3AFQmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 11:42:04 -0500
Received: by mail-vb0-f50.google.com with SMTP id ft2so6775043vbb.9
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 08:42:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d0434bf1e6d88f004d2a16439
Content-Type: text/plain; charset=UTF-8

The ping6 command can use either openssl or gnutls...
and the Makefile has a bunch of setup for defining which of the two to use.

Unfortunately, the final -D define on the commandline to enable gnutls
inside the ping6.c file didn't actually make it onto the gcc
commandline.
This patch adds the $(DEF_CRYPTO) Makefile variable to fix this gap.

Signed-off-by: Arjan van de Ven <arjanvandeven@gmail.com>

--f46d0434bf1e6d88f004d2a16439
Content-Type: application/octet-stream; name="build.patch"
Content-Disposition: attachment; filename="build.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hbmespo70

VGhlIHBpbmc2IGNvbW1hbmQgY2FuIHVzZSBlaXRoZXIgb3BlbnNzbCBvciBnbnV0bHMuLi4KYW5k
IHRoZSBNYWtlZmlsZSBoYXMgYSBidW5jaCBvZiBzZXR1cCBmb3IgZGVmaW5pbmcgd2hpY2ggb2Yg
dGhlIHR3byB0byB1c2UuCgpVbmZvcnR1bmF0ZWx5LCB0aGUgZmluYWwgLUQgZGVmaW5lIG9uIHRo
ZSBjb21tYW5kbGluZSB0byBlbmFibGUgZ251dGxzIGluc2lkZSB0aGUgcGluZzYuYyBmaWxlIGRp
ZG4ndCBhY3R1YWxseSBtYWtlIGl0IG9udG8gdGhlIGdjYyBjb21tYW5kbGluZS4KVGhpcyBwYXRj
aCBhZGRzIHRoZSAkKERFRl9DUllQVE8pIE1ha2VmaWxlIHZhcmlhYmxlIHRvIGZpeCB0aGlzIGdh
cC4KClNpZ25lZC1vZmYtYnk6IEFyamFuIHZhbiBkZSBWZW4gPGFyamFudmFuZGV2ZW5AZ21haWwu
Y29tPgoKLS0tIGlwdXRpbHMtczIwMTIxMjIxL01ha2VmaWxlfgkyMDEyLTEyLTIxIDA2OjAxOjA3
LjAwMDAwMDAwMCAtMDgwMAorKysgaXB1dGlscy1zMjAxMjEyMjEvTWFrZWZpbGUJMjAxMy0wMS0w
NiAwODoyNzo1Ni4wMTQ4OTE4NDYgLTA4MDAKQEAgLTE0OSw3ICsxNDksNyBAQAogREVGX3Bpbmdf
Y29tbW9uID0gJChERUZfQ0FQKSAkKERFRl9JRE4pCiBERUZfcGluZyAgPSAkKERFRl9DQVApICQo
REVGX0lETikgJChERUZfV0lUSE9VVF9JRkFERFJTKQogTElCX3BpbmcgID0gJChMSUJfQ0FQKSAk
KExJQl9JRE4pCi1ERUZfcGluZzYgPSAkKERFRl9DQVApICQoREVGX0lETikgJChERUZfV0lUSE9V
VF9JRkFERFJTKSAkKERFRl9FTkFCTEVfUElORzZfUlRIRFIpCitERUZfcGluZzYgPSAkKERFRl9D
QVApICQoREVGX0lETikgJChERUZfV0lUSE9VVF9JRkFERFJTKSAkKERFRl9FTkFCTEVfUElORzZf
UlRIRFIpICQoREVGX0NSWVBUTykKIExJQl9waW5nNiA9ICQoTElCX0NBUCkgJChMSUJfSUROKSAk
KExJQl9SRVNPTFYpICQoTElCX0NSWVBUTykKIAogcGluZzogcGluZ19jb21tb24ubwo=
--f46d0434bf1e6d88f004d2a16439--
