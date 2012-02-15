From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: tc - mqprio formatted print fix
Date: Wed, 15 Feb 2012 17:02:33 +0100
Message-ID: <1329321753-18081-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: netdev@vger.kernel.org, ppisar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab2BOQGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 11:06:09 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1FG69vX015806
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 11:06:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a minor correction of mqprio printf()'s.

Reported-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 tc/q_mqprio.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/q_mqprio.c b/tc/q_mqprio.c
index bf734a0..b2d8c12 100644
--- a/tc/q_mqprio.c
+++ b/tc/q_mqprio.c
@@ -116,10 +116,10 @@ int mqprio_print_opt(struct qdisc_util *qu, FILE =
*f, struct rtattr *opt)
=20
 	fprintf(f, " tc %u map ", qopt->num_tc);
 	for (i =3D 0; i <=3D TC_PRIO_MAX; i++)
-		fprintf(f, "%d ", qopt->prio_tc_map[i]);
+		fprintf(f, "%u ", qopt->prio_tc_map[i]);
 	fprintf(f, "\n             queues:");
 	for (i =3D 0; i < qopt->num_tc; i++)
-		fprintf(f, "(%i:%i) ", qopt->offset[i],
+		fprintf(f, "(%u:%u) ", qopt->offset[i],
 			qopt->offset[i] + qopt->count[i] - 1);
 	return 0;
 }
--=20
1.7.7.6
