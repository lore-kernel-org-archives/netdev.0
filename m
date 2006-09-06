From: Greg KH <gregkh@suse.de>
Subject: [patch 32/37] sky2: accept flow control
Date: Wed, 6 Sep 2006 15:57:51 -0700
Message-ID: <20060906225751.GG15922@kroah.com>
References: <20060906224631.999046890@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964977AbWIFXIy@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename="sky2-pause-fixes.patch"
In-Reply-To: <20060906225444.GA15922@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@osdl.org>

Don't program the GMAC to reject flow control packets.
This maybe the cause of some of the transmit hangs.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.17.11.orig/drivers/net/sky2.h
+++ linux-2.6.17.11/drivers/net/sky2.h
@@ -1566,7 +1566,7 @@ enum {
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC | GMR_FS_GOOD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 

--
