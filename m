From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 1 Sep 2003 03:11:58 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010257390.26242-200000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309010249070.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-279846508-1062375118=:26242"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.44.0309010249070.26242-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-279846508-1062375118=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

unless (link-local) protocols like DHCPv6 or MLD are run over the virtual
link formed by IPv6 tunnels, the net_devices representing the tunnels
don't necessarily need to have an IPv6 address configured specifically to
them.

The inet6_dev structure of the device must however be configured for
neighbor discovery to work properly, even for IFF_NOARP devices like
ip6_tnls. This patch fixes that issue. Please apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-279846508-1062375118=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_tnl_addrconf.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309010311580.26242@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_tnl_addrconf.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTI3Ni4yOC40IC0+IDEuMTI3Ni4y
OC41DQojCSBuZXQvaXB2Ni9hZGRyY29uZi5jCTEuNjMgICAgLT4gMS42NCAg
IA0KIw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdl
U2V0IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQ0KIyAwMy8wOS8wMQl2bnVvcnZhbEBkc2wtaGtpZ3cxYThi
LmRpYWwuaW5ldC5maQkxLjEyNzYuMjguNQ0KIyBBbGxvdyBhbiBJUHY2LUlQ
djYgdHVubmVsIGRldmljZSB0byBzZW5kIHBhY2tldHMgd2l0aG91dCBjb25m
aWd1cmluZw0KIyBhIHNlcGFyYXRlIElQdjYgYWRkcmVzcyB0byBpdC4NCiMg
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0N
CiMNCmRpZmYgLU5ydSBhL25ldC9pcHY2L2FkZHJjb25mLmMgYi9uZXQvaXB2
Ni9hZGRyY29uZi5jDQotLS0gYS9uZXQvaXB2Ni9hZGRyY29uZi5jCU1vbiBT
ZXAgIDEgMDE6NTg6NDUgMjAwMw0KKysrIGIvbmV0L2lwdjYvYWRkcmNvbmYu
YwlNb24gU2VwICAxIDAxOjU4OjQ1IDIwMDMNCkBAIC0xODE5LDYgKzE4MTks
MjAgQEANCiB9DQogDQogDQorI2lmIGRlZmluZWQoQ09ORklHX0lQVjZfVFVO
TkVMKSB8fCBkZWZpbmVkKENPTkZJR19JUFY2X1RVTk5FTF9NT0RVTEUpDQor
c3RhdGljIHZvaWQgYWRkcmNvbmZfaXA2X3RubF9jb25maWcoc3RydWN0IG5l
dF9kZXZpY2UgKmRldikNCit7DQorCXN0cnVjdCBpbmV0Nl9kZXYgKmlkZXY7
DQorDQorCUFTU0VSVF9SVE5MKCk7DQorDQorCWlmICgoaWRldiA9IGlwdjZf
ZmluZF9pZGV2KGRldikpID09IE5VTEwpIHsNCisJCXByaW50ayhLRVJOX0RF
QlVHICJpbml0IGlwNi1pcDY6IGZpbmRfZGV2IGZhaWxlZFxuIik7DQorCQly
ZXR1cm47DQorCX0NCit9DQorI2VuZGlmDQorDQogaW50IGFkZHJjb25mX25v
dGlmeShzdHJ1Y3Qgbm90aWZpZXJfYmxvY2sgKnRoaXMsIHVuc2lnbmVkIGxv
bmcgZXZlbnQsIA0KIAkJICAgIHZvaWQgKiBkYXRhKQ0KIHsNCkBAIC0xODMx
LDcgKzE4NDUsMTEgQEANCiAJCWNhc2UgQVJQSFJEX1NJVDoNCiAJCQlhZGRy
Y29uZl9zaXRfY29uZmlnKGRldik7DQogCQkJYnJlYWs7DQotDQorI2lmIGRl
ZmluZWQoQ09ORklHX0lQVjZfVFVOTkVMKSB8fCBkZWZpbmVkKENPTkZJR19J
UFY2X1RVTk5FTF9NT0RVTEUpDQorCQljYXNlIEFSUEhSRF9UVU5ORUw2Og0K
KwkJCWFkZHJjb25mX2lwNl90bmxfY29uZmlnKGRldik7DQorCQkJYnJlYWs7
DQorI2VuZGlmDQogCQljYXNlIEFSUEhSRF9MT09QQkFDSzoNCiAJCQlpbml0
X2xvb3BiYWNrKGRldik7DQogCQkJYnJlYWs7DQo=
---377318441-279846508-1062375118=:26242--
