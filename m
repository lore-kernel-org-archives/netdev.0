From: "D. S. Ljungmark" <spider@takeit.se>
Subject: ipv6 : Don't reduce hop limit below current value
Date: Tue, 24 Mar 2015 22:36:09 +0100
Message-ID: <1427232969.3276.4.camel@takeit.se>
Reply-To: ljungmark@modio.se
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-OhgWhgcfwpc0MBcGMU0O"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36297 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbbCXVgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:36:14 -0400
Received: by lbbug6 with SMTP id ug6so4311701lbb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:36:12 -0700 (PDT)
Received: from waves.skuggor.se ([2001:470:ddd2:1::4f9])
        by mx.google.com with ESMTPSA id h3sm97970lam.49.2015.03.24.14.36.10
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 14:36:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OhgWhgcfwpc0MBcGMU0O
Content-Type: multipart/mixed; boundary="=-rP/Q8YeaeXhFd2l1EDwe"


--=-rP/Q8YeaeXhFd2l1EDwe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

A local route may have a lower hop_limit set than global routes do.


See RFC 3756 Section 4.2.7

--=-rP/Q8YeaeXhFd2l1EDwe
Content-Disposition: attachment;
	filename="0001-ipv6-Don-t-reduce-hop-limit-for-an-interface.patch"
Content-Type: text/x-patch;
	name="0001-ipv6-Don-t-reduce-hop-limit-for-an-interface.patch";
	charset="UTF-8"
Content-Transfer-Encoding: base64

RnJvbSA4NDZlNjQ4YWM4ZWE5MzI1Nzc4YTYxMDM4YTA5ZDk4YzJmYjcwMDJhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiAiRC5TLiBManVuZ21hcmsiIDxzcGlkZXJAc2t1Z2dvci5zZT4K
RGF0ZTogVHVlLCAyNCBNYXIgMjAxNSAyMjoxODo0NyArMDEwMApTdWJqZWN0OiBbUEFUQ0hdIGlw
djY6IERvbid0IHJlZHVjZSBob3AgbGltaXQgZm9yIGFuIGludGVyZmFjZQoKQSBsb2NhbCByb3V0
ZSBtYXkgaGF2ZSBhIGxvd2VyIGhvcF9saW1pdCBzZXQgdGhhbiBnbG9iYWwgcm91dGVzIGRvLgpT
ZWUgUkZDIDM3NTYgU2VjdGlvbiA0LjIuNwoKU2lnbmVkLW9mZi1ieTogRC5TLiBManVuZ21hcmsg
PGxqdW5nbWFya0Btb2Rpby5zZT4KLS0tCiBuZXQvaXB2Ni9uZGlzYy5jIHwgOSArKysrKysrKy0K
IDEgZmlsZSBjaGFuZ2VkLCA4IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1n
aXQgYS9uZXQvaXB2Ni9uZGlzYy5jIGIvbmV0L2lwdjYvbmRpc2MuYwppbmRleCA0NzFlZDI0Li5i
OTM5NjUyIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9uZGlzYy5jCisrKyBiL25ldC9pcHY2L25kaXNj
LmMKQEAgLTEyMTgsNyArMTIxOCwxNCBAQCBzdGF0aWMgdm9pZCBuZGlzY19yb3V0ZXJfZGlzY292
ZXJ5KHN0cnVjdCBza19idWZmICpza2IpCiAJaWYgKHJ0KQogCQlydDZfc2V0X2V4cGlyZXMocnQs
IGppZmZpZXMgKyAoSFogKiBsaWZldGltZSkpOwogCWlmIChyYV9tc2ctPmljbXBoLmljbXA2X2hv
cF9saW1pdCkgewotCQlpbjZfZGV2LT5jbmYuaG9wX2xpbWl0ID0gcmFfbXNnLT5pY21waC5pY21w
Nl9ob3BfbGltaXQ7CisJCS8qCU9ubHkgc2V0IGhvcF9saW1pdCBvbiB0aGUgaW50ZXJmYWNlIGlm
IGl0IGlzIGhpZ2hlciB0aGFuCisJCSoJdGhlIGN1cnJlbnQgaG9wX2xpbWl0LgorCQkgKi8KKwkJ
aWYgKGluNl9kZXYtPmNuZi5ob3BfbGltaXQgPCByYV9tc2ctPmljbXBoLmljbXA2X2hvcF9saW1p
dCkgeworCQkJaW42X2Rldi0+Y25mLmhvcF9saW1pdCA9IHJhX21zZy0+aWNtcGguaWNtcDZfaG9w
X2xpbWl0OworCQl9IGVsc2UgeworCQkJTkRfUFJJTlRLKDIsIHdhcm4sICJSQTogR290IHJvdXRl
IGFkdmVydGlzZW1lbnQgd2l0aCBsb3dlciBob3BfbGltaXQgdGhhbiBjdXJyZW50XG4iKTsKKwkJ
fQogCQlpZiAocnQpCiAJCQlkc3RfbWV0cmljX3NldCgmcnQtPmRzdCwgUlRBWF9IT1BMSU1JVCwK
IAkJCQkgICAgICAgcmFfbXNnLT5pY21waC5pY21wNl9ob3BfbGltaXQpOwotLSAKMi4xLjAKCg==


--=-rP/Q8YeaeXhFd2l1EDwe--

--=-OhgWhgcfwpc0MBcGMU0O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVEdjJAAoJEPzDdnREnjz8ZHkQAI1jCoCFLEgALDMBaJ/qk6n+
b9f6uKcilbu56erbwFRm9QwkaJNO8bFGanooHyme7vuU9hQQVqspFMA1lNXTx3LB
JlL2AYwvTT/KPiFedHhaQmjTuYHfMUX+yCqa2VtA4MBod/S6Br1Q5wLgXgQ1clty
e6hrLO+AmweIa6XukHiVjb+mXkPAheLNtV3eN7LEZG44vLXpMezRUpKwswCT0kc3
CEXJqiRG+/qdX/PzG2kiG6aJCSLMuXujelWTMT9i7gfm+rLBXoC2GS1Ib0RKgtJl
9ozKAWl5jeVZHsyVzj/FjyB3GlpUOvqeyqE1L6xss+iEagGRNio2KsCfSCrenHJJ
0bsw6QCGubLQg0h+rRrg8vpqX8D2YNej92GlCDrEQ7D4htyDt0YYE72T9C07LZMZ
CuXYA3gJUDV1Y+a/N9qVvyBPgX4jOeU5YbketQSOiuxEomkQ4oEzAnGAZOibrT/n
Q39ebaVAhFwMGb/3LWPu3S+oFkoxixrMv4bCk2xtRd+NiaWdfN33LomvwyZw8Zqg
yfmH5oR7NcZlmI8k5IDB6rlQCz2jMo1ihnYQx9Z8b/0v8kN0GS7Jbd0+ErGIUjQO
tIu4Z1e3zqjkh39zVvRhYBKWw7qfgSfwryasQNt3vQY6DRUz1kSQYly28ADtDgSN
tIUyyJiJ2R283wn3AsgF
=xEVB
-----END PGP SIGNATURE-----

--=-OhgWhgcfwpc0MBcGMU0O--
