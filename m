From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: mac80211 fixes for 2.6.22
Date: Mon, 11 Jun 2007 21:16:16 -0400
Message-ID: <20070612011616.GC20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few mac80211 patches appropriate for 2.6.22.

Individual patches to follow, or you can pull at your leisure...

John

---

The following changes since commit 5ecd3100e695228ac5e0ce0e325e252c0f11806f:
  Linus Torvalds (1):
        Linux 2.6.22-rc4

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git mac80211-fixes

David Lamparter (1):
      cfg80211: fix signed macaddress in sysfs

Johannes Berg (1):
      mac80211: fix debugfs tx power reduction output

Mattias Nissler (1):
      mac80211: Don't stop tx queue on master device while scanning.

 net/mac80211/debugfs.c       |    2 +-
 net/mac80211/ieee80211_sta.c |   12 ++++++++++++
 net/wireless/sysfs.c         |    2 +-
 3 files changed, 14 insertions(+), 2 deletions(-)

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
