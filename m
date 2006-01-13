From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] schedule SHAPER for removal
Date: Fri, 13 Jan 2006 15:13:43 +0100
Message-ID: <20060113141343.GM29663@stusta.de>
References: <20060111003747.GJ3911@stusta.de> <1136940409.3435.126.camel@localhost.localdomain> <200601110153.21989.ak@suse.de> <1136944738.28616.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, David Woodhouse <dwmw2@infradead.org>,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422687AbWAMONo@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1136944738.28616.0.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2006 at 01:58:58AM +0000, Alan Cox wrote:
> On Mer, 2006-01-11 at 01:53 +0100, Andi Kleen wrote:
> > shaper is completely obsolete and it's probably best to just remove
> > all references to it and the kernel driver too.
> 
> I would agree with that but it nees to go through a proper obsolesence
> and obliteration cycle not just vanish.

Patch below.

cu
Adrian


<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.15-mm3-full/Documentation/feature-removal-schedule.txt.old	2006-01-13 15:02:15.000000000 +0100
+++ linux-2.6.15-mm3-full/Documentation/feature-removal-schedule.txt	2006-01-13 15:06:19.000000000 +0100
@@ -164,0 +165,6 @@
+---------------------------
+
+What:   Traffic Shaper (CONFIG_SHAPER)
+When:   July 2006
+Why:    obsoleted by the code in net/sched/
+Who:    Adrian Bunk <bunk@stusta.de
--- linux-2.6.15-mm3-full/drivers/net/Kconfig.old	2006-01-13 15:06:34.000000000 +0100
+++ linux-2.6.15-mm3-full/drivers/net/Kconfig	2006-01-13 15:06:49.000000000 +0100
@@ -2663,7 +2663,7 @@
 	  "SCSI generic support".
 
 config SHAPER
-	tristate "Traffic Shaper (EXPERIMENTAL)"
+	tristate "Traffic Shaper (OBSOLETE)"
 	depends on EXPERIMENTAL
 	---help---
 	  The traffic shaper is a virtual network device that allows you to
