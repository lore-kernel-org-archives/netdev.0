From: root@smtp.nexlab.net
Subject: (no subject)
Date: Tue, 24 May 2005 11:17:24 +0200 (CEST)
Message-ID: <20050524091724.B2F48FA3F@smtp.nexlab.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients:;
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	by smtp.nexlab.net (Postfix) with ESMTP id 346A4FA13

	for <buffer@sniffo.org>; Tue, 24 May 2005 03:28:34 +0200 (CEST)

Received: from oss (localhost [127.0.0.1])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1ScF3000570;

	Mon, 23 May 2005 18:28:39 -0700

Received: with ECARTIS (v1.0.0; list netdev); Mon, 23 May 2005 18:27:46 -0700 (PDT)

Received: from MMS2.broadcom.com (mms2.broadcom.com [216.31.210.18])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1RhF3032603

	for <netdev@oss.sgi.com>; Mon, 23 May 2005 18:27:43 -0700

Received: from 10.10.64.121 by MMS2.broadcom.com with SMTP (Broadcom

 SMTP Relay (Email Firewall v6.1.0)); Mon, 23 May 2005 18:26:49 -0700

X-Server-Uuid: 1F20ACF3-9CAF-44F7-AB47-F294E2D5B4EA

Received: from mail-irva-8.broadcom.com ([10.10.64.221]) by

 mail-irva-1.broadcom.com (Post.Office MTA v3.5.3 release 223 ID#

 0-72233U7200L2200S0V35) with ESMTP id com; Mon, 23 May 2005 18:26:48

 -0700

Received: from mon-irva-10.broadcom.com (mon-irva-10.broadcom.com

 [10.10.64.171]) by mail-irva-8.broadcom.com (MOS 3.5.6-GR) with ESMTP

 id AZY38167; Mon, 23 May 2005 18:26:47 -0700 (PDT)

Received: from nt-irva-0741.brcm.ad.broadcom.com (

 nt-irva-0741.brcm.ad.broadcom.com [10.8.194.54]) by

 mon-irva-10.broadcom.com (8.9.1/8.9.1) with ESMTP id SAA16842; Mon, 23

 May 2005 18:26:47 -0700 (PDT)

Received: from 10.7.17.55 ([10.7.17.55]) by

 NT-IRVA-0741.brcm.ad.broadcom.com ([10.8.194.54]) with Microsoft

 Exchange Server HTTP-DAV ; Tue, 24 May 2005 01:26:47 +0000

Received: from rh4 by nt-irva-0741; 23 May 2005 17:29:03 -0700

Subject: [PATCH 4/6] bnx2: Fix bug in bnx2_close

From: "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
In-Reply-To: <1116892439.4908.1.camel@rh4>

References: <1116892439.4908.1.camel@rh4>

Date: Mon, 23 May 2005 17:29:03 -0700

Message-ID: <1116894543.4908.32.camel@rh4>

MIME-Version: 1.0

X-Mailer: Evolution 2.0.2 (2.0.2-3)

X-WSS-ID: 6E8C5D531VO1443816-01-01

Content-Type: multipart/mixed;

 boundary="=-kVtupVzl5sY8iZGVxtrc"

X-archive-position: 1533

X-ecartis-version: Ecartis v1.0.0

Sender: netdev-bounce@oss.sgi.com
Errors-To: netdev-bounce@oss.sgi.com
X-original-sender: mchan@broadcom.com

Precedence: bulk

X-list: netdev

X-Virus-Scanned: ClamAV 0.83/892/Mon May 23 10:52:19 2005 on oss.sgi.com

X-Virus-Status: Clean




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
