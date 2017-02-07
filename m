From: Sreedhar <sreedhar.donelli@tcs.com>
Subject: [PATCH] arm-proc-root-undeclared-error
Date: Tue, 7 Feb 2017 14:37:28 +0530
Message-ID: <1486458448-5199-3-git-send-email-sreedhar.donelli@tcs.com>
References: <1486458448-5199-1-git-send-email-sreedhar.donelli@tcs.com>
Cc: sreedhar donelli <sreedhar.donelli@tcs.com>
To: davem@davemloft.net, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486458448-5199-1-git-send-email-sreedhar.donelli@tcs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sreedhar donelli <sreedhar.donelli@tcs.com>

---
 net/atm/clip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 53b4ac0..7a7cb4a 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -930,8 +930,9 @@ static void atm_clip_exit_noproc(void)
 
 static void __exit atm_clip_exit(void)
 {
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("arp", atm_proc_root);
-
+#endif
 	atm_clip_exit_noproc();
 }
 
-- 
1.9.1

=====-----=====-----=====
Notice: The information contained in this e-mail
message and/or attachments to it may contain 
confidential or privileged information. If you are 
not the intended recipient, any dissemination, use, 
review, distribution, printing or copying of the 
information contained in this e-mail message 
and/or attachments to it are strictly prohibited. If 
you have received this communication in error, 
please notify us by reply e-mail or telephone and 
immediately and permanently delete the message 
and any attachments. Thank you
