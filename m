From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-10-13
Date: Tue, 13 Oct 2015 10:59:47 +0200
Message-ID: <1444726787.1961.7.camel@sipsolutions.net>
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

There are just two small fixes, but I didn't really want to wait since
I have nothing else pending.

Let me know if there's any problem.

johannes

The following changes since commit babc305e21ea3811d98b67437299360904ac1b6a:

  mac80211: reset CQM history upon reconfiguration (2015-09-22 15:22:50 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-10-13

for you to fetch changes up to 4633dfc32c0019bed2996de9bbdbe7f3b518a44e:

  mac80211: Fix hwflags debugfs file format (2015-10-13 10:30:56 +0200)

----------------------------------------------------------------
Like last time, we have two small fixes:
 * fast-xmit was not doing powersave filter clearing correctly,
   disable fast-xmit while any such operations are still pending
 * a debugfs file was broken due to some infrastructure changes

----------------------------------------------------------------
Felix Fietkau (1):
      mac80211: fix handling of PS filtering with fast-xmit

Mohammed Shafi Shajakhan (1):
      mac80211: Fix hwflags debugfs file format

 net/mac80211/debugfs.c | 2 +-
 net/mac80211/status.c  | 1 +
 net/mac80211/tx.c      | 7 +++++--
 3 files changed, 7 insertions(+), 3 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
