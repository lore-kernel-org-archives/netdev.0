From: Julian Anastasov <ja@ssi.bg>
Subject: [patches] invalid nh.raw use after free
Date: Wed, 16 Jul 2003 02:41:00 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307160233540.14682-400000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-670464987-1058312460=:14682"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-670464987-1058312460=:14682
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	The attached patches fix similar bug to many places (I'm not
sure if there are more instances), where pointers remain to refer to 
freed skbs. For 2.5 and 2.4.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-670464987-1058312460=:14682
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ipip_old_iph-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0307160241000.14682@u.domain.uli>
Content-Description: ipip
Content-Disposition: attachment; filename="ipip_old_iph-1.diff"

LS0tIGxpbnV4L25ldC9pcHY0L2lwaXAuYy5vbGRfaXBoCVNhdCBKdWwgMTIg
MTE6MDk6MjkgMjAwMw0KKysrIGxpbnV4L25ldC9pcHY0L2lwaXAuYwlXZWQg
SnVsIDE2IDAyOjE4OjQxIDIwMDMNCkBAIC02MTYsNiArNjE2LDcgQEANCiAJ
CQlza2Jfc2V0X293bmVyX3cobmV3X3NrYiwgc2tiLT5zayk7DQogCQlkZXZf
a2ZyZWVfc2tiKHNrYik7DQogCQlza2IgPSBuZXdfc2tiOw0KKwkJb2xkX2lw
aCA9IHNrYi0+bmguaXBoOw0KIAl9DQogDQogCXNrYi0+bmgucmF3ID0gc2ti
X3B1c2goc2tiLCBzaXplb2Yoc3RydWN0IGlwaGRyKSk7DQo=
--1607745702-670464987-1058312460=:14682
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip_gre_old_iph-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0307160241001.14682@u.domain.uli>
Content-Description: ip_gre
Content-Disposition: attachment; filename="ip_gre_old_iph-1.diff"

LS0tIGxpbnV4L25ldC9pcHY0L2lwX2dyZS5jLm9sZF9pcGgJU2F0IEp1bCAx
MiAxMTowOToyOSAyMDAzDQorKysgbGludXgvbmV0L2lwdjQvaXBfZ3JlLmMJ
V2VkIEp1bCAxNiAwMjoxMjo1NiAyMDAzDQpAQCAtODE2LDYgKzgxNiw3IEBA
DQogCQkJc2tiX3NldF9vd25lcl93KG5ld19za2IsIHNrYi0+c2spOw0KIAkJ
ZGV2X2tmcmVlX3NrYihza2IpOw0KIAkJc2tiID0gbmV3X3NrYjsNCisJCW9s
ZF9pcGggPSBza2ItPm5oLmlwaDsNCiAJfQ0KIA0KIAlza2ItPm5oLnJhdyA9
IHNrYl9wdXNoKHNrYiwgZ3JlX2hsZW4pOw0K
--1607745702-670464987-1058312460=:14682
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="sit_iph6-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0307160241002.14682@u.domain.uli>
Content-Description: sit
Content-Disposition: attachment; filename="sit_iph6-1.diff"

LS0tIGxpbnV4L25ldC9pcHY2L3NpdC5jLm9sZF9pcGg2CVNhdCBKdWwgMTIg
MTE6MDk6MjkgMjAwMw0KKysrIGxpbnV4L25ldC9pcHY2L3NpdC5jCVdlZCBK
dWwgMTYgMDI6MjM6MDYgMjAwMw0KQEAgLTU1MCw2ICs1NTAsNyBAQA0KIAkJ
CXNrYl9zZXRfb3duZXJfdyhuZXdfc2tiLCBza2ItPnNrKTsNCiAJCWRldl9r
ZnJlZV9za2Ioc2tiKTsNCiAJCXNrYiA9IG5ld19za2I7DQorCQlpcGg2ID0g
c2tiLT5uaC5pcHY2aDsNCiAJfQ0KIA0KIAlza2ItPm5oLnJhdyA9IHNrYl9w
dXNoKHNrYiwgc2l6ZW9mKHN0cnVjdCBpcGhkcikpOw0K
--1607745702-670464987-1058312460=:14682--
