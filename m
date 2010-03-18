From: Joe Perches <joe@perches.com>
Subject: [PATCH v2 0/7] wireless: Use macros from wireless.h
Date: Wed, 17 Mar 2010 23:21:33 -0700
Message-ID: <cover.1268892663.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pavel Roskin <proski@gnu.org>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	Corey Thomas <coreythomas@charter.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the STD_IW_HANDLER macro from orinoco to wireless.h
Use the wireless.h macros in various wireless files
Remove local #defines of IW_IOCTL

Joe Perches (7):
  wireless.h: Add STD_IW_HANDLER macro
  net/wireless/wext_core.c: Use IW_IOCTL_IDX macro
  net/wireless/wext-core.c: Use IW_EVENT_IDX macro
  drivers/net/wireless: Use STD_IW_HANDLER macro
  drivers/net: Remove local #define IW_IOCTL, use STD_IW_HANDLER
  orinoco/wext.c: Remove local #define STD_IW_HANDLER
  wireless.h: Use SIOCIWFIRST not SIOCSIWCOMMIT for range check

 drivers/net/ps3_gelic_wireless.c       |   35 ++++----
 drivers/net/wireless/ipw2x00/ipw2200.c |   83 ++++++++++----------
 drivers/net/wireless/orinoco/wext.c    |    2 -
 drivers/net/wireless/ray_cs.c          |   40 +++++-----
 drivers/net/wireless/wl3501_cs.c       |   52 ++++++------
 include/linux/wireless.h               |    4 +-
 net/wireless/wext-core.c               |  134 ++++++++++++++++----------------
 7 files changed, 174 insertions(+), 176 deletions(-)
