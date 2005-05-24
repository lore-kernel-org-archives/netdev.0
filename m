From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/6] bnx2: Fix rx checksum
Date: Mon, 23 May 2005 17:26:23 -0700
Message-ID: <1116894383.4908.29.camel@rh4>
References: <1116892439.4908.1.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-MjP9kNbfLluHpwDwIMre"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <1116892439.4908.1.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-MjP9kNbfLluHpwDwIMre
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Fix bug in rx checksum by indicating CHECKSUM_UNNECESSARY only when the
hw calculated checksum is 0xffff.

Spotted by Jeff Garzik.

Signed-off-by: Michael Chan <mchan@broadcom.com>


--=-MjP9kNbfLluHpwDwIMre
Content-Disposition: attachment;
 filename=bnx2-12.patch
Content-Type: text/x-patch;
 charset=utf-8;
 name=bnx2-12.patch
Content-Transfer-Encoding: base64

ZGlmZiAtTnJ1IDExL2RyaXZlcnMvbmV0L2JueDIuYyAxMi9kcml2ZXJzL25ldC9ibngyLmMNCi0t
LSAxMS9kcml2ZXJzL25ldC9ibngyLmMJMjAwNS0wNS0yMyAxMDoyMDoyMC4wMDAwMDAwMDAgLTA3
MDANCisrKyAxMi9kcml2ZXJzL25ldC9ibngyLmMJMjAwNS0wNS0yMyAxMDoyOTowMi4wMDAwMDAw
MDAgLTA3MDANCkBAIC0xNDcwLDkgKzE0NzAsOCBAQA0KIA0KIAkJCXUxNiBja3N1bSA9IHJ4X2hk
ci0+bDJfZmhkcl90Y3BfdWRwX3hzdW07DQogDQotCQkJaWYgKChja3N1bSA9PSAweGZmZmYpIHx8
IChja3N1bSA9PSAwKSkgew0KKwkJCWlmIChja3N1bSA9PSAweGZmZmYpDQogCQkJCXNrYi0+aXBf
c3VtbWVkID0gQ0hFQ0tTVU1fVU5ORUNFU1NBUlk7DQotCQkJfQ0KIAkJfQ0KIA0KICNpZmRlZiBC
Q01fVkxBTg0K


--=-MjP9kNbfLluHpwDwIMre--
