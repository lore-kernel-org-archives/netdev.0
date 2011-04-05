From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 15/34] baycom: Drop __TIME__ usage
Date: Tue,  5 Apr 2011 16:59:02 +0200
Message-ID: <1302015561-21047-16-git-send-email-mmarek@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Cc: linux-kernel@vger.kernel.org,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 drivers/net/hamradio/baycom_epp.c     |    2 +-
 drivers/net/hamradio/baycom_par.c     |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c |    2 +-
 drivers/net/hamradio/baycom_ser_hdx.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index a3c0dc9..9537aaa 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -69,7 +69,7 @@ static const char paranoia_str[] = KERN_ERR
 
 static const char bc_drvname[] = "baycom_epp";
 static const char bc_drvinfo[] = KERN_INFO "baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA\n"
-"baycom_epp: version 0.7 compiled " __TIME__ " " __DATE__ "\n";
+"baycom_epp: version 0.7\n";
 
 /* --------------------------------------------------------------------- */
 
diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index 5f5af9a..279d229 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -102,7 +102,7 @@
 
 static const char bc_drvname[] = "baycom_par";
 static const char bc_drvinfo[] = KERN_INFO "baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA\n"
-"baycom_par: version 0.9 compiled " __TIME__ " " __DATE__ "\n";
+"baycom_par: version 0.9\n";
 
 /* --------------------------------------------------------------------- */
 
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 3e25f10..99cdce3 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -92,7 +92,7 @@
 
 static const char bc_drvname[] = "baycom_ser_fdx";
 static const char bc_drvinfo[] = KERN_INFO "baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA\n"
-"baycom_ser_fdx: version 0.10 compiled " __TIME__ " " __DATE__ "\n";
+"baycom_ser_fdx: version 0.10\n";
 
 /* --------------------------------------------------------------------- */
 
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index 1686f6d..d92fe6c 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -80,7 +80,7 @@
 
 static const char bc_drvname[] = "baycom_ser_hdx";
 static const char bc_drvinfo[] = KERN_INFO "baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA\n"
-"baycom_ser_hdx: version 0.10 compiled " __TIME__ " " __DATE__ "\n";
+"baycom_ser_hdx: version 0.10\n";
 
 /* --------------------------------------------------------------------- */
 
-- 
1.7.4.1
