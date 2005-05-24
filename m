From: root@smtp.nexlab.net
Subject: (no subject)
Date: Tue, 24 May 2005 11:17:28 +0200 (CEST)
Message-ID: <20050524091728.DB86AFA44@smtp.nexlab.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients:;
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	by smtp.nexlab.net (Postfix) with ESMTP id CE413FA1F

	for <buffer@sniffo.org>; Tue, 24 May 2005 03:30:17 +0200 (CEST)

Received: from oss (localhost [127.0.0.1])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1QmF3031979;

	Mon, 23 May 2005 18:26:48 -0700

Received: with ECARTIS (v1.0.0; list netdev); Mon, 23 May 2005 18:25:08 -0700 (PDT)

Received: from MMS2.broadcom.com (mms2.broadcom.com [216.31.210.18])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1P4F3031331

	for <netdev@oss.sgi.com>; Mon, 23 May 2005 18:25:04 -0700

Received: from 10.10.64.121 by MMS2.broadcom.com with SMTP (Broadcom

 SMTP Relay (Email Firewall v6.1.0)); Mon, 23 May 2005 18:24:08 -0700

X-Server-Uuid: 1F20ACF3-9CAF-44F7-AB47-F294E2D5B4EA

Received: from mail-irva-8.broadcom.com ([10.10.64.221]) by

 mail-irva-1.broadcom.com (Post.Office MTA v3.5.3 release 223 ID#

 0-72233U7200L2200S0V35) with ESMTP id com; Mon, 23 May 2005 18:24:07

 -0700

Received: from mon-irva-10.broadcom.com (mon-irva-10.broadcom.com

 [10.10.64.171]) by mail-irva-8.broadcom.com (MOS 3.5.6-GR) with ESMTP

 id AZY37732; Mon, 23 May 2005 18:24:07 -0700 (PDT)

Received: from nt-irva-0741.brcm.ad.broadcom.com (

 nt-irva-0741.brcm.ad.broadcom.com [10.8.194.54]) by

 mon-irva-10.broadcom.com (8.9.1/8.9.1) with ESMTP id SAA16376; Mon, 23

 May 2005 18:24:06 -0700 (PDT)

Received: from 10.7.17.55 ([10.7.17.55]) by

 NT-IRVA-0741.brcm.ad.broadcom.com ([10.8.194.54]) with Microsoft

 Exchange Server HTTP-DAV ; Tue, 24 May 2005 01:24:06 +0000

Received: from rh4 by nt-irva-0741; 23 May 2005 17:26:23 -0700

Subject: [PATCH 2/6] bnx2: Fix rx checksum

From: "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
In-Reply-To: <1116892439.4908.1.camel@rh4>

References: <1116892439.4908.1.camel@rh4>

Date: Mon, 23 May 2005 17:26:23 -0700

Message-ID: <1116894383.4908.29.camel@rh4>

MIME-Version: 1.0

X-Mailer: Evolution 2.0.2 (2.0.2-3)

X-WSS-ID: 6E8C5DB21VO1443376-01-01

Content-Type: multipart/mixed;

 boundary="=-MjP9kNbfLluHpwDwIMre"

X-archive-position: 1531

X-ecartis-version: Ecartis v1.0.0

Sender: netdev-bounce@oss.sgi.com
Errors-To: netdev-bounce@oss.sgi.com
X-original-sender: mchan@broadcom.com

Precedence: bulk

X-list: netdev

X-Virus-Scanned: ClamAV 0.83/892/Mon May 23 10:52:19 2005 on oss.sgi.com

X-Virus-Status: Clean




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
