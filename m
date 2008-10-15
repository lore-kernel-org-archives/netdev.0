From: c4p7n@capitanio.org
Subject: [patch] rtl8102e: commit 7bf6bf480 zeroized MAC address
Date: Wed, 15 Oct 2008 12:11:11 +0200 (MEST)
Message-ID: <200810151011.m9FABBRj025271@post.webmailer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="b35edecca28e3b641189a4386a6f35978"
Cc: kernel@vger.kernel.org, netdev@vger.kernel.org,
	c4p7n1@capitanio.org
To: netdev@vger.kernel.org, "Francois Romieu" <romieu@fr.zoreil.com>,
	"Ivan Vecera" <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.225]:35923 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbYJOKWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 06:22:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--b35edecca28e3b641189a4386a6f35978
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Tested on top of linus tree and back ported 2.6.27.

Please cc me, thanks
Martin Capitanio






--b35edecca28e3b641189a4386a6f35978
Content-Type: message/rfc822; name="r8169-01.patch"
Content-disposition: attachment; filename="r8169-01.patch"
Content-Transfer-Encoding: base64


ZCBPY3QgMTUgMTA6NTM6MDIgMjAwOCArMDIwMAoKICAgIENvbW1pdCA3YmY2YmY0ODAzZGYxYWRj
OTI3ZjU4NTE2OGQyMTM1ZmIwMTljNjk4IGJyb2tlIHRoZSBpbiBiZXR3ZWVuCiAgICBmbGF3bGVz
c2x5IHdvcmtpbmcgcmVhbHRlayBjaGlwc2V0IHJ0bDgxMDJlLiBUaGUgbWFjIGFkZHJlc3MgaXMg
aGVyZSBfbm90XwogICAgbG9jYXRlZCBpbiB0aGUgRUVQUk9NIGF0IG9mZnNldCAweDBlIGFuZCBp
dCBpcyAoYXQgbGVhc3QgZm9yIHRoaXMgbm90ZWJvb2spCiAgICBub3QgbmVlZGVkLiBBZnRlciBh
IHJlYm9vdCBpcyB0aGUgb3JpZ2luYWwgTUFDIGFkZHJlc3MgYXV0b21hZ2ljYWxseQogICAgcmVz
dG9yZWQuCgogICAgWyAgICA4LjI0MjM0OV0gcjgxNjkgR2lnYWJpdCBFdGhlcm5ldCBkcml2ZXIg
Mi4zTEstTkFQSSBsb2FkZWQKICAgIFsgICAgOC4yNDI0MzRdIHI4MTY5IDAwMDA6MDI6MDAuMDog
UENJIElOVCBBIC0+IEdTSSAxNiAobGV2ZWwsIGxvdykgLT4gSVJRIDE2CiAgICBbICAgIDguMjQy
NTE3XSByODE2OSAwMDAwOjAyOjAwLjA6IHNldHRpbmcgbGF0ZW5jeSB0aW1lciB0byA2NAogICAg
WyAgICA4LjI0MzU0OF0gZXRoMDogUlRMODEwMmUgYXQgMHhmZmZmYzIwMDAwMDRhMDAwLCAwMDow
MDowMDowMDowMDowMCwgWElEIDM0YTAwMDAwIElSUSAzMTYKCgpkaWZmIC0tZ2l0IGEvZHJpdmVy
cy9uZXQvcjgxNjkuYyBiL2RyaXZlcnMvbmV0L3I4MTY5LmMKaW5kZXggYzgyMWRhMi4uODRiM2Qz
MSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvcjgxNjkuYworKysgYi9kcml2ZXJzL25ldC9yODE2
OS5jCkBAIC0yMTU2LDcgKzIxNTYsMTIgQEAgcnRsODE2OV9pbml0X29uZShzdHJ1Y3QgcGNpX2Rl
diAqcGRldiwgY29uc3Qgc3RydWN0IHBjaV9kZXZpY2VfaWQgKmVudCkKIAogCXRwLT5tbWlvX2Fk
ZHIgPSBpb2FkZHI7CiAKLQlydGxfaW5pdF9tYWNfYWRkcmVzcyh0cCwgaW9hZGRyKTsKKwlpZih0
cC0+bWFjX3ZlcnNpb24gPT0gUlRMX0dJR0FfTUFDX1ZFUl8wOSkKKwl7CisJCWRwcmludGsoIlJl
YWRpbmcgTUFDIGFkZHJlc3MgZnJvbSBFRVBST00gaXMgbm90IHN1cHBvcnRlZFxuIik7CisJfSBl
bHNlIHsKKwkJcnRsX2luaXRfbWFjX2FkZHJlc3ModHAsIGlvYWRkcik7CisJfQogCiAJLyogR2V0
IE1BQyBhZGRyZXNzICovCiAJZm9yIChpID0gMDsgaSA8IE1BQ19BRERSX0xFTjsgaSsrKQo=


--b35edecca28e3b641189a4386a6f35978--
