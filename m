From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-01-23
Date: Fri, 23 Jan 2015 16:33:08 +0100
Message-ID: <1422027188.2728.37.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I have a few more fixes that seemed relevant for the current cycle and
low enough impact to merge at this point.

However, I can live with all of this going to -next as well since most
are difficult to hit in practice.

johannes


The following changes since commit 20658702e08ecd693236b443837d28863b93e872:

  cfg80211: fix deadlock during reg chan check (2015-01-07 14:53:46 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-01-23

for you to fetch changes up to 0fa7b39131576dd1baa6ca17fca53c65d7f62249:

  nl80211: fix per-station group key get/del and memory leak (2015-01-23 11:21:02 +0100)

----------------------------------------------------------------
Another set of last-minute fixes:
 * fix station double-removal when suspending while associating
 * fix the HT (802.11n) header length calculation
 * fix the CCK radiotap flag used for monitoring, a pretty
   old regression but a simple one-liner
 * fix per-station group-key handling

----------------------------------------------------------------
Fred Chou (1):
      mac80211: correct header length calculation

Johannes Berg (1):
      nl80211: fix per-station group key get/del and memory leak

Luciano Coelho (1):
      mac80211: only roll back station states for WDS when suspending

Mathy Vanhoef (1):
      mac80211: properly set CCK flag in radiotap

 net/mac80211/pm.c      | 29 +++++++++++++++--------------
 net/mac80211/rx.c      |  2 +-
 net/wireless/nl80211.c |  9 ++++-----
 net/wireless/util.c    |  6 ++++++
 4 files changed, 26 insertions(+), 20 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
