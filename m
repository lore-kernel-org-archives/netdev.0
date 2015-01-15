From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-01-15
Date: Thu, 15 Jan 2015 13:48:00 +0100
Message-ID: <1421326080.1962.10.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Hope it's not too late for 3.19 - we found two more issues, pull request
below.

Thanks,
johannes

The following changes since commit 1e359a5de861a57aa04d92bb620f52a5c1d7f8b1:

  Revert "mac80211: Fix accounting of the tailroom-needed counter" (2015-01-05 10:33:46 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-01-15

for you to fetch changes up to 20658702e08ecd693236b443837d28863b93e872:

  cfg80211: fix deadlock during reg chan check (2015-01-07 14:53:46 +0100)

----------------------------------------------------------------
Just two fixes - one for an uninialized variable and
one for a deadlock in regulatory processing.

----------------------------------------------------------------
Arik Nemtsov (1):
      cfg80211: fix deadlock during reg chan check

John Linville (1):
      mac80211: uninitialized return val in __ieee80211_sta_handle_tspec_ac_params

 net/mac80211/mlme.c |  2 +-
 net/wireless/reg.c  | 56 ++++++++++++++++++++++++++++++++---------------------
 2 files changed, 35 insertions(+), 23 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
