From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 6/7] lnstat: dump to stdout, not stderr
Date: Mon, 13 Apr 2015 16:01:00 +0200
Message-ID: <1428933661-8193-6-git-send-email-pavlix@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47552 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205AbbDMOKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:05 -0400
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

See also:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D736332

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 misc/lnstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index 32b5cbe..e105b70 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -347,7 +347,7 @@ int main(int argc, char **argv)
=20
 	switch (mode) {
 	case MODE_DUMP:
-		lnstat_dump(stderr, lnstat_files);
+		lnstat_dump(stdout, lnstat_files);
 		break;
=20
 	case MODE_NORMAL:
--=20
2.3.5
