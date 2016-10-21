From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] Revert "kexec: Export kexec_in_progress to modules"
Date: Fri, 21 Oct 2016 14:21:55 -0700
Message-ID: <1477084916-26327-2-git-send-email-f.fainelli@gmail.com>
References: <1477084916-26327-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        ebiederm@xmission.com, kexec@lists.infradead.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477084916-26327-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 97dcaa0fcfd24daa9a36c212c1ad1d5a97759212. Based on
the review discussion with Eric, we will come up with a different fix
for the bcm_sf2 driver which does not make it rely on the
kexec_in_progress value.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 kernel/kexec_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 786ab85a5452..561675589511 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -59,7 +59,6 @@ size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
 
 /* Flag to indicate we are going to kexec a new kernel */
 bool kexec_in_progress = false;
-EXPORT_SYMBOL_GPL(kexec_in_progress);
 
 
 /* Location of the reserved area for the crash kernel */
-- 
2.7.4
