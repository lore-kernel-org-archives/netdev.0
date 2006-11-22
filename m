From: Jiri Benc <jbenc@suse.cz>
Subject: d80211: pull request
Date: Wed, 22 Nov 2006 17:47:34 +0100
Message-ID: <20061122174734.781c18d1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:22442 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1755518AbWKVQrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 11:47:36 -0500
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
to obtain following patches:

David Kimdon:
      d80211: Remove unused ENABLE_COMPRESSION, DISABLE_COMPRESSION cmds to hw->set_key

Johannes Berg:
      d80211: clean up some stupid list and loop code
      d80211: reduce mdev usage
      d80211: reduce mdev usage
      d80211: reduce mdev usage, change ieee80211_rx_mgmt
      d80211: reduce master ieee80211_ptr deref in scan routines
      d80211: change the identifier netdev to ieee80211_hw
      d80211: add a perm_addr hardware property
      d80211: remove useless driver name field
      d80211: remove IEEE80211_CONF_SW_{EN,DE}CRYPT
      d80211: remove calib_int
      d80211: use ieee80211_hw.dev

I won't attach the patches this time as some of them are quite big and all
of them went to netdev a few days ago. Please note that these patches break
all d80211 drivers.


 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    4 
 include/net/d80211.h                               |  253 ++++----
 include/net/d80211_common.h                        |    2 
 net/d80211/ieee80211.c                             |  618 +++++++++++---------
 net/d80211/ieee80211_dev.c                         |    8 
 net/d80211/ieee80211_i.h                           |   39 +
 net/d80211/ieee80211_iface.c                       |   34 -
 net/d80211/ieee80211_ioctl.c                       |  260 ++++----
 net/d80211/ieee80211_led.c                         |   12 
 net/d80211/ieee80211_scan.c                        |  105 ++-
 net/d80211/ieee80211_sta.c                         |  179 +++---
 net/d80211/ieee80211_sysfs.c                       |   40 +
 net/d80211/sta_info.c                              |   40 +
 net/d80211/wme.c                                   |   31 -
 net/d80211/wpa.c                                   |   50 +-
 15 files changed, 852 insertions(+), 823 deletions(-)

-- 
Jiri Benc
SUSE Labs
