From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-02-27
Date: Fri, 27 Feb 2015 14:44:30 +0100
Message-ID: <1425044670.1960.3.camel@sipsolutions.net>
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

Please pull some fixes I've currently accumulated - including the one
for Linus's four-way-handshake problem.

Let me know if there are any issues.

Thanks,
Johannes


The following changes since commit 6514890f7aa8dd75fa46e282a1c7a8615e86f363:

  tcp: fix tcp_should_expand_sndbuf() to use tcp_packets_in_flight() (2015-02-22 23:07:11 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-02-27

for you to fetch changes up to 9c1c98a3bb7b7593b60264b9a07e001e68b46697:

  mac80211: Send EAPOL frames at lowest rate (2015-02-26 21:03:06 +0100)

----------------------------------------------------------------
A few patches have accumulated, among them the fix for Linus's
four-way-handshake problem. The others are various small fixes
for problems all over, nothing really stands out.

----------------------------------------------------------------
Bob Copeland (1):
      mac80211_hwsim: fix error handling in tx_frame_nl

Eliad Peller (1):
      mac80211: clear sdata->radar_required

Jason Abele (1):
      cfg80211: fix n_reg_rules to match world_regdom

Jiri Slaby (1):
      mac80211/minstrel: fix !x!=0 confusion

Johannes Berg (1):
      nl80211: fix memory leak in monitor flags parsing

Jouni Malinen (1):
      mac80211: Send EAPOL frames at lowest rate

Junjie Mao (1):
      cfg80211: calls nl80211_exit on error

Samuel Tan (1):
      nl80211: use loop index as type for net detect frequency results

 drivers/net/wireless/mac80211_hwsim.c |  5 ++++-
 net/mac80211/chan.c                   |  5 +++++
 net/mac80211/rc80211_minstrel.c       |  2 +-
 net/mac80211/tx.c                     |  1 +
 net/wireless/core.c                   |  1 +
 net/wireless/nl80211.c                | 12 +++++-------
 net/wireless/reg.c                    |  2 +-
 7 files changed, 18 insertions(+), 10 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
