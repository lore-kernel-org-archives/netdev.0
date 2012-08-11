From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 07/15] packet: declaring packet protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:10 +0900
Message-ID: <1344715638-22997-7-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring packet protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/packet/af_packet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ceaca7c..6a0e47c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2564,6 +2564,7 @@ static struct proto packet_proto = {
 	.name	  = "PACKET",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct packet_sock),
+	.has_own_proc_entry= 1,
 };
 
 /*
-- 
1.7.11.2
