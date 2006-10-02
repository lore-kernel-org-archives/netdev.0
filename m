From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Please pull bcm43xx-d80211 bugfixes and new features
Date: Mon, 2 Oct 2006 18:43:20 +0200
Message-ID: <200610021843.20694.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please pull from my tree
git pull http://bu3sch.de/git/wireless-dev.git for-linville

This will pull various bugfixes and feature improvements.
Most noteably it will pull a bugfix for a crash introduced
by an earlier patch to d80211 which changed RX status information
handling.

The new features include support for the new v4 firmware.
I also did my homework to get better support for OpenWRT
devices in ssb.


The list of pulled changesets is:

Michael Buesch:
      ssb: Abstract bus accesses.
      bcm43xx-d80211: convert to ssb abstract bus access API
      bcm43xx-d80211: Don't crash if we use v4 firmware.
      bcm43xx-d80211: Always make fwpostfix option available.
      bcm43xx-d80211: Firmware revision/patchlevel detection.
      bcm43xx-d80211: Add support for v4 firmware.
      bcm43xx-d80211: add SHM constants
      bcm43xx-d80211: Don't use low level netif and ieee80211_netif_oper functions.
      bcm43xx-d80211: DMA-mask fixes.
      bcm43xx-d80211: Remove some BCM947XX ifdefs,
      Merge branch 'master' of git://kernel.org/.../linville/wireless-dev
      bcm43xx-d80211: Assign all fields in the RX status report.
      bcm43xx-d80211: Set channel cookie to prevent ghost packets.
      bcm43xx-d80211: Prevent crash by setting active wlcore to NULL on wlcore-select failure.


The diffstat is:

 drivers/misc/ssb.c                                 |  431 ++++++-----
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |  143 +++
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c  |  295 +++-----
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h  |   35 -
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |  149 ++--
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h  |   18 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c |   16 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |  820 +++++++++-----------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c  |   76 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |  104 +--
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h  |   12 
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.c    |  125 +---
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.c    |  143 ++--
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.h    |    1 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |  309 +++++++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h |  247 +++++-
 include/linux/ssb.h                                |   71 +-
 17 files changed, 1681 insertions(+), 1314 deletions(-)

-- 
Greetings Michael.
