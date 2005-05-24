From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/6] bnx2: Fix bug in bnx2_close
Date: Mon, 23 May 2005 17:29:03 -0700
Message-ID: <1116894543.4908.32.camel@rh4>
References: <1116892439.4908.1.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-kVtupVzl5sY8iZGVxtrc"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <1116892439.4908.1.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-kVtupVzl5sY8iZGVxtrc
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Fix bug in bnx2_close() by calling flush_scheduled_work() since we are
using a work queue in netdev watchdog. Also added bnx2_netif_stop() call
in bnx2_close().

Spotted by Jeff Garzik.

Signed-off-by: Michael Chan <mchan@broadcom.com>


--=-kVtupVzl5sY8iZGVxtrc
Content-Disposition: attachment;
 filename=bnx2-14.patch
Content-Type: text/x-patch;
 charset=utf-8;
 name=bnx2-14.patch
Content-Transfer-Encoding: base64

ZGlmZiAtTnJ1IDEzL2RyaXZlcnMvbmV0L2JueDIuYyAxNC9kcml2ZXJzL25ldC9ibngyLmMNCi0t
LSAxMy9kcml2ZXJzL25ldC9ibngyLmMJMjAwNS0wNS0yMyAxMDo1Nzo0MS4wMDAwMDAwMDAgLTA3
MDANCisrKyAxNC9kcml2ZXJzL25ldC9ibngyLmMJMjAwNS0wNS0yMyAxMzowMTo0NS4wMDAwMDAw
MDAgLTA3MDANCkBAIC00MTcyLDcgKzQxNzIsOCBAQA0KIAlzdHJ1Y3QgYm54MiAqYnAgPSBkZXYt
PnByaXY7DQogCXUzMiByZXNldF9jb2RlOw0KIA0KLQlibngyX2Rpc2FibGVfaW50X3N5bmMoYnAp
Ow0KKwlmbHVzaF9zY2hlZHVsZWRfd29yaygpOw0KKwlibngyX25ldGlmX3N0b3AoYnApOw0KIAlk
ZWxfdGltZXJfc3luYygmYnAtPnRpbWVyKTsNCiAJaWYgKGJwLT53b2wpDQogCQlyZXNldF9jb2Rl
ID0gQk5YMl9EUlZfTVNHX0NPREVfU1VTUEVORF9XT0w7DQo=


--=-kVtupVzl5sY8iZGVxtrc--
