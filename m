From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Protect proxied addresses against DAD
Date: Wed, 20 Aug 2003 14:40:14 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308201423500.541-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-2045924552-1061379614=:541"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-2045924552-1061379614=:541
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

a proxy has to reply to DAD probes, otherwise it can't protect its
addresses. The attached patch fixes this, please apply!

Thanks,
Ville

PS. Dave, you misspelled my email address in csets 1.1199.1.10,
1.1199.1.12 and 1.1199.1.16 ;)
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-2045924552-1061379614=:541
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="proxy_dad.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0308201440140.541@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="proxy_dad.patch"

LS0tIGxpbnV4LTIuNS5PTEQvbmV0L2lwdjYvbmRpc2MuYwkyMDAzLTA4LTIw
IDE0OjEwOjE2LjAwMDAwMDAwMCArMDMwMA0KKysrIGxpbnV4LTIuNS9uZXQv
aXB2Ni9uZGlzYy5jCTIwMDMtMDgtMjAgMTQ6MTA6MzAuMDAwMDAwMDAwICsw
MzAwDQpAQCAtODYxLDcgKzg2MSw4IEBADQogCQlzdHJ1Y3QgaW5ldDZfZGV2
ICppbjZfZGV2ID0gaW42X2Rldl9nZXQoZGV2KTsNCiANCiAJCWlmIChpbjZf
ZGV2ICYmIGluNl9kZXYtPmNuZi5mb3J3YXJkaW5nICYmDQotCQkgICAgKGFk
ZHJfdHlwZSAmIElQVjZfQUREUl9VTklDQVNUKSAmJg0KKwkJICAgIChhZGRy
X3R5cGUgJiBJUFY2X0FERFJfVU5JQ0FTVCB8fA0KKwkJICAgICBhZGRyX3R5
cGUgPT0gSVBWNl9BRERSX0FOWSkgJiYNCiAJCSAgICBwbmVpZ2hfbG9va3Vw
KCZuZF90YmwsICZtc2ctPnRhcmdldCwgZGV2LCAwKSkgew0KIAkJCWludCBp
bmMgPSBpcHY2X2FkZHJfdHlwZShkYWRkcikmSVBWNl9BRERSX01VTFRJQ0FT
VDsNCiANCkBAIC04NzQsMTIgKzg3NSwyMCBAQA0KIAkJCQllbHNlDQogCQkJ
CQluZF90Ymwuc3RhdHMucmN2X3Byb2Jlc191Y2FzdCsrOw0KIAkJCQkJDQot
CQkJCW5laWdoID0gbmVpZ2hfZXZlbnRfbnMoJm5kX3RibCwgbGxhZGRyLCBz
YWRkciwgZGV2KTsNCisJCQkJaWYgKGFkZHJfdHlwZSAmIElQVjZfQUREUl9V
TklDQVNUKSB7DQorCQkJCQluZWlnaCA9IG5laWdoX2V2ZW50X25zKCZuZF90
YmwsIGxsYWRkciwgc2FkZHIsIGRldik7DQogDQotCQkJCWlmIChuZWlnaCkg
ew0KLQkJCQkJbmRpc2Nfc2VuZF9uYShkZXYsIG5laWdoLCBzYWRkciwgJm1z
Zy0+dGFyZ2V0LA0KLQkJCQkJCSAgICAgIDAsIDEsIDAsIDEpOw0KLQkJCQkJ
bmVpZ2hfcmVsZWFzZShuZWlnaCk7DQorCQkJCQlpZiAobmVpZ2gpIHsNCisJ
CQkJCQluZGlzY19zZW5kX25hKGRldiwgbmVpZ2gsIHNhZGRyLCAmbXNnLT50
YXJnZXQsDQorCQkJCQkJCSAgICAgIDAsIDEsIDAsIDEpOw0KKwkJCQkJCW5l
aWdoX3JlbGVhc2UobmVpZ2gpOw0KKwkJCQkJfQ0KKwkJCQl9IGVsc2Ugew0K
KwkJCQkJLyogcHJveHkgc2hvdWxkIGFsc28gcHJvdGVjdCBhZ2FpbnN0IERB
RCAqLw0KKwkJCQkJc3RydWN0IGluNl9hZGRyIG1hZGRyOw0KKwkJCQkJaXB2
Nl9hZGRyX2FsbF9ub2RlcygmbWFkZHIpOw0KKwkJCQkJbmRpc2Nfc2VuZF9u
YShkZXYsIE5VTEwsICZtYWRkciwgJm1zZy0+dGFyZ2V0LCANCisJCQkJCQkg
ICAgICAwLCAwLCAwLCAxKTsNCiAJCQkJfQ0KIAkJCX0gZWxzZSB7DQogCQkJ
CXN0cnVjdCBza19idWZmICpuID0gc2tiX2Nsb25lKHNrYiwgR0ZQX0FUT01J
Qyk7DQo=
---377318441-2045924552-1061379614=:541--
