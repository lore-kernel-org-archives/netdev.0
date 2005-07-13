From: Greg KH <gregkh@suse.de>
Subject: [05/11] SMP fix for 6pack driver
Date: Wed, 13 Jul 2005 11:43:31 -0700
Message-ID: <20050713184331.GG9330@kroah.com>
References: <20050713184130.GA9330@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262367AbVGMVQq@vger.kernel.org>
To: ralf@linux-mips.org, netdev@vger.kernel.org, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050713184130.GA9330@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------


Drivers really only work well in SMP if they actually can be selected.
This is a leftover from the time when the 6pack drive only used to be
a bitrotten variant of the slip driver.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>
Signed-off-by: Chris Wright <chrisw@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 drivers/net/hamradio/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.12.2.orig/drivers/net/hamradio/Kconfig	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12.2/drivers/net/hamradio/Kconfig	2005-07-13 10:56:32.000000000 -0700
@@ -17,7 +17,7 @@
 
 config 6PACK
 	tristate "Serial port 6PACK driver"
-	depends on AX25 && BROKEN_ON_SMP
+	depends on AX25
 	---help---
 	  6pack is a transmission protocol for the data exchange between your
 	  PC and your TNC (the Terminal Node Controller acts as a kind of
