From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 00/16] wl1251 patches from linux-n900 tree
Date: Sat, 26 Oct 2013 22:33:59 +0200
Message-ID: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, I'm sending wl1251 patches from linux-n900 tree [1] for comments=
=2E More
patches come from David's monitor & packet injection work. Patches are =
tested
with 3.12 rc5 kernel on Nokia N900.

[1] - https://gitorious.org/linux-n900/linux-n900

David Gnedt (13):
  mac80211: fix TX device statistics for monitor interfaces
  wl1251: fix scan behaviour while not associated
  wl1251: add sysfs interface for bluetooth coexistence mode
    configuration
  wl1251: retry power save entry
  wl1251: implement hardware ARP filtering
  wl1251: split RX and TX data path initialisation
  wl1251: configure hardware en-/decryption for monitor mode
  wl1251: implement multicast address filtering
  wl1251: disable power saving in monitor mode
  wl1251: fix channel switching in monitor mode
  wl1251: enable tx path in monitor mode if necessary for packet
    injection
  wl1251: disable retry and ACK policy for injected packets
  wl1251: enforce changed hw encryption support on monitor state change

Pali Roh=C3=A1r (3):
  wl1251: add nvs file name to module firmware list
  wl1251: Add sysfs file tx_mgmt_frm_rate for setting rate
  wl1251: Add sysfs file address for setting permanent mac address

 drivers/net/wireless/ti/wl1251/acx.c    |   97 ++++++-
 drivers/net/wireless/ti/wl1251/acx.h    |   34 ++-
 drivers/net/wireless/ti/wl1251/boot.c   |    3 +-
 drivers/net/wireless/ti/wl1251/cmd.c    |   50 +++-
 drivers/net/wireless/ti/wl1251/cmd.h    |    8 +-
 drivers/net/wireless/ti/wl1251/event.c  |   44 +++
 drivers/net/wireless/ti/wl1251/event.h  |    7 +
 drivers/net/wireless/ti/wl1251/init.c   |   19 +-
 drivers/net/wireless/ti/wl1251/main.c   |  460 +++++++++++++++++++++++=
+++++++-
 drivers/net/wireless/ti/wl1251/rx.c     |    2 +-
 drivers/net/wireless/ti/wl1251/tx.c     |   27 +-
 drivers/net/wireless/ti/wl1251/wl1251.h |   14 +
 net/mac80211/tx.c                       |    3 +
 13 files changed, 715 insertions(+), 53 deletions(-)

--=20
1.7.10.4
