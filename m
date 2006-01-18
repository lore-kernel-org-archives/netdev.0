From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] schedule eepro100.c for removal
Date: Wed, 18 Jan 2006 08:41:54 +0100
Message-ID: <20060118074154.GH19398@stusta.de>
References: <20060105181826.GD12313@stusta.de> <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru> <20060115160340.6f8cc7d6@localhost.localdomain> <20060117184834.GD19398@stusta.de> <56a8daef0601171427s75894fid0f8c4f9e2b28e50@mail.gmail.com> <20060118003232.GA28965@tuxdriver.com> <43CD8D72.6040501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	John Ronciak <john.ronciak@gmail.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030306AbWARHl5@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43CD8D72.6040501@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2006 at 07:36:02PM -0500, Jeff Garzik wrote:
> John W. Linville wrote:
> >On Tue, Jan 17, 2006 at 02:27:16PM -0800, John Ronciak wrote:
> >
> >
> >>Another thing is that removal of the driver (or disabling the config)
> >>will hopefully force the issue in that people with these ARCHs will
> >>use the e100 and if they have problems we can get them fixed in the
> >>e100 driver.  At this point nobody seems to be able to define a "real"
> >>problem other than talking about it.
> 
> Someone should send me a patch that adds eepro100 to the feature-removal 
> doc.

Patch below.

> 	jeff

cu
Adrian


<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt.old	2006-01-18 08:38:57.000000000 +0100
+++ linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt	2006-01-18 08:39:59.000000000 +0100
@@ -164,0 +165,6 @@
+---------------------------
+
+What:   eepro100 network driver
+When:   April 2006
+Why:    replaced by the e100 driver
+Who:    Adrian Bunk <bunk@stusta.de>
