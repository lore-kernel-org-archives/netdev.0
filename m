From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev updated -- 23 November 2006
Date: Thu, 23 Nov 2006 11:33:14 -0500
Message-ID: <20061123163308.GA8287@tuxdriver.com>
References: <20061122174734.781c18d1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, flamingice@sourmilk.net,
	ivdoorn@gmail.com, mb@bu3sch.de, hong.liu@intel.com,
	mabbas@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:64016 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1757328AbWKWQ6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 11:58:35 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061122174734.781c18d1@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 05:47:34PM +0100, Jiri Benc wrote:

> please pull from
> git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
> to obtain following patches:

As you wish...

> I won't attach the patches this time as some of them are quite big and all
> of them went to netdev a few days ago. Please note that these patches break
> all d80211 drivers.

Driver authors, please observe the warning above.

The following changes since commit 0669bb0d858df91b17f3912341078f49842f82f3:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

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

John W. Linville:
      Merge git://git.kernel.org/.../jbenc/dscape

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
John W. Linville
linville@tuxdriver.com
