From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] parisc: fix SO_MAX_PACING_RATE typo
Date: Thu, 16 Jan 2014 11:15:12 -0800
Message-ID: <1389899712.31367.419.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389888898-31744-1-git-send-email-msekleta@redhat.com>
	  <52D80BCA.7030400@redhat.com> <20140116172631.GA5206@loki.brq.redhat.com>
	  <52D82626.5060701@redhat.com>
	 <1389898146.31367.413.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52D82A7A.3090106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:35329 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaAPTPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:15:15 -0500
Received: by mail-yh0-f53.google.com with SMTP id b20so806233yha.40
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 11:15:14 -0800 (PST)
In-Reply-To: <52D82A7A.3090106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

SO_MAX_PACING_RATE definition on parisc got a typo.
Its not too late to fix it, before 3.13 is official.

Fixes: 62748f32d501 ("net: introduce SO_MAX_PACING_RATE")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 arch/parisc/include/uapi/asm/socket.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f33113a6141e..70b3674dac4e 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -75,6 +75,6 @@
 
 #define SO_BUSY_POLL		0x4027
 
-#define SO_MAX_PACING_RATE	0x4048
+#define SO_MAX_PACING_RATE	0x4028
 
 #endif /* _UAPI_ASM_SOCKET_H */
