From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPV4] Remove unsupported DNAT (RTCF_NAT and RTCF_NAT) in IPV4
Date: Wed, 2 Jan 2008 23:31:37 +0200
Message-ID: <eb3ff54b0801021331w63637142sd39b6605bd6f8be4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5911_766461.1199309497124"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:58842 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757764AbYABVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 16:31:39 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3226282fga.17
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 13:31:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5911_766461.1199309497124
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

- The DNAT (Destination NAT) is not implemented in IPV4.

- This patch remove the code which checks these flags
in net/ipv4/arp.c and net/ipv4/route.c.

The RTCF_NAT and RTCF_NAT should stay in the header (linux/in_route.h)
because they are used in DECnet.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5911_766461.1199309497124
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faydu48s0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2FycC5jIGIvbmV0L2lwdjQvYXJwLmMKaW5kZXggMTQxNmJj
OS4uMmI3MmJhNiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvYXJwLmMKKysrIGIvbmV0L2lwdjQvYXJw
LmMKQEAgLTgzNSw5ICs4MzUsOCBAQCBzdGF0aWMgaW50IGFycF9wcm9jZXNzKHN0cnVjdCBza19i
dWZmICpza2IpCiAJCQl9CiAJCQlnb3RvIG91dDsKIAkJfSBlbHNlIGlmIChJTl9ERVZfRk9SV0FS
RChpbl9kZXYpKSB7Ci0JCQlpZiAoKHJ0LT5ydF9mbGFncyZSVENGX0ROQVQpIHx8Ci0JCQkgICAg
KGFkZHJfdHlwZSA9PSBSVE5fVU5JQ0FTVCAgJiYgcnQtPnUuZHN0LmRldiAhPSBkZXYgJiYKLQkJ
CSAgICAgKGFycF9md2RfcHJveHkoaW5fZGV2LCBydCkgfHwgcG5laWdoX2xvb2t1cCgmYXJwX3Ri
bCwgJmluaXRfbmV0LCAmdGlwLCBkZXYsIDApKSkpIHsKKwkJCSAgICBpZiAoYWRkcl90eXBlID09
IFJUTl9VTklDQVNUICAmJiBydC0+dS5kc3QuZGV2ICE9IGRldiAmJgorCQkJICAgICAoYXJwX2Z3
ZF9wcm94eShpbl9kZXYsIHJ0KSB8fCBwbmVpZ2hfbG9va3VwKCZhcnBfdGJsLCAmaW5pdF9uZXQs
ICZ0aXAsIGRldiwgMCkpKSB7CiAJCQkJbiA9IG5laWdoX2V2ZW50X25zKCZhcnBfdGJsLCBzaGEs
ICZzaXAsIGRldik7CiAJCQkJaWYgKG4pCiAJCQkJCW5laWdoX3JlbGVhc2Uobik7CmRpZmYgLS1n
aXQgYS9uZXQvaXB2NC9yb3V0ZS5jIGIvbmV0L2lwdjQvcm91dGUuYwppbmRleCAxMDkxNWJiLi5l
ZTljOTNjIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9yb3V0ZS5jCisrKyBiL25ldC9pcHY0L3JvdXRl
LmMKQEAgLTE3NjgsNyArMTc2OCw3IEBAIHN0YXRpYyBpbmxpbmUgaW50IF9fbWtyb3V0ZV9pbnB1
dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCWlmIChlcnIpCiAJCWZsYWdzIHw9IFJUQ0ZfRElSRUNU
U1JDOwogCi0JaWYgKG91dF9kZXYgPT0gaW5fZGV2ICYmIGVyciAmJiAhKGZsYWdzICYgKFJUQ0Zf
TkFUIHwgUlRDRl9NQVNRKSkgJiYKKwlpZiAob3V0X2RldiA9PSBpbl9kZXYgJiYgZXJyICYmICEo
ZmxhZ3MgJiBSVENGX01BU1EpICYmCiAJICAgIChJTl9ERVZfU0hBUkVEX01FRElBKG91dF9kZXYp
IHx8CiAJICAgICBpbmV0X2FkZHJfb25saW5rKG91dF9kZXYsIHNhZGRyLCBGSUJfUkVTX0dXKCpy
ZXMpKSkpCiAJCWZsYWdzIHw9IFJUQ0ZfRE9SRURJUkVDVDsKQEAgLTE3NzcsNyArMTc3Nyw3IEBA
IHN0YXRpYyBpbmxpbmUgaW50IF9fbWtyb3V0ZV9pbnB1dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAog
CQkvKiBOb3QgSVAgKGkuZS4gQVJQKS4gRG8gbm90IGNyZWF0ZSByb3V0ZSwgaWYgaXQgaXMKIAkJ
ICogaW52YWxpZCBmb3IgcHJveHkgYXJwLiBETkFUIHJvdXRlcyBhcmUgYWx3YXlzIHZhbGlkLgog
CQkgKi8KLQkJaWYgKG91dF9kZXYgPT0gaW5fZGV2ICYmICEoZmxhZ3MgJiBSVENGX0ROQVQpKSB7
CisJCWlmIChvdXRfZGV2ID09IGluX2RldikgewogCQkJZXJyID0gLUVJTlZBTDsKIAkJCWdvdG8g
Y2xlYW51cDsKIAkJfQo=
------=_Part_5911_766461.1199309497124--
