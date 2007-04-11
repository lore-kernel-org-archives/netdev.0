From: Greg KH <gregkh@suse.de>
Subject: [patch 05/31] sky2: turn carrier off when down
Date: Wed, 11 Apr 2007 15:51:29 -0700
Message-ID: <20070411225129.GF24814@kroah.com>
References: <20070411224329.866978349@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161401AbXDKXDt@vger.kernel.org>
Content-Disposition: inline; filename="sky2-carrier.patch"
In-Reply-To: <20070411225100.GA24814@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Driver needs to turn off carrier when down.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1506,6 +1506,7 @@ static int sky2_down(struct net_device *
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);

-- 
