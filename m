From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Sat, 12 Jan 2008 11:40:17 +0200
Message-ID: <12001308174189-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308172525-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817467-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53008 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760950AbYALJkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:19 -0500
In-Reply-To: <1200130817467-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/core/pktgen.c:
  pktgen_stop_device   |  -50
  pktgen_run           | -105
  pktgen_if_show       |  -37
  pktgen_thread_worker | -702
 4 functions changed, 894 bytes removed, diff: -894

net/core/pktgen.c:
  getCurUs |  +36
 1 function changed, 36 bytes added, diff: +36

net/core/pktgen.o:
 5 functions changed, 36 bytes added, 894 bytes removed, diff: -858

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ebfb126..d18fdb1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -405,7 +405,7 @@ static inline __u64 tv_to_us(const struct timeval *=
tv)
 	return us;
 }
=20
-static inline __u64 getCurUs(void)
+static __u64 getCurUs(void)
 {
 	struct timeval tv;
 	do_gettimeofday(&tv);
--=20
1.5.0.6

