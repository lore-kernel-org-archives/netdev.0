From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] sctp: fix compile warnings in sctp_tsnmap_num_gabs
Date: Sun, 20 Feb 2011 15:57:26 +0800
Message-ID: <4D60C966.2000302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>,
	SCTP-Maillist <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57789 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab1BTH7o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 02:59:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/sctp/tsnmap.c: In function =E2=80=98sctp_tsnmap_num_gabs=E2=80=99:
net/sctp/tsnmap.c:347: warning: =E2=80=98start=E2=80=99 may be used uni=
nitialized in this function
net/sctp/tsnmap.c:347: warning: =E2=80=98end=E2=80=99 may be used unini=
tialized in this function

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/sctp/tsnmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index 747d541..f1e40ce 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -344,7 +344,7 @@ __u16 sctp_tsnmap_num_gabs(struct sctp_tsnmap *map,
=20
 	/* Refresh the gap ack information. */
 	if (sctp_tsnmap_has_gap(map)) {
-		__u16 start, end;
+		__u16 start =3D 0, end =3D 0;
 		sctp_tsnmap_iter_init(map, &iter);
 		while (sctp_tsnmap_next_gap_ack(map, &iter,
 						&start,
--=20
1.6.3.3

