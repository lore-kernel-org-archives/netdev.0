From: "=?UTF-8?q?=E2=80=9CCosmin?=" <cosmin90stanescu@gmail.com>
Subject: [PATCH] strict_strtoul in (obsolete) changed to kstrtoul
Date: Thu, 11 Jul 2013 09:52:42 +0300
Message-ID: <1373525562-9035-1-git-send-email-user@mjolnir>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhowells@redhat.com, ebiederm@xmission.com, rusty@rustcorp.com.au,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: =E2=80=9CCosmin <=E2=80=9Ccosmin90stanescu@gmail.com=E2=80=
=9D>
---
 net/dns_resolver/dns_key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 0a69d07..f347a2c 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -118,7 +118,7 @@ dns_resolver_instantiate(struct key *key, struct ke=
y_preparsed_payload *prep)
 				if (opt_vlen <=3D 0)
 					goto bad_option_value;
=20
-				ret =3D strict_strtoul(eq, 10, &derrno);
+				ret =3D kstrtoul(eq, 10, &derrno);
 				if (ret < 0)
 					goto bad_option_value;
=20
--=20
1.7.10.4
