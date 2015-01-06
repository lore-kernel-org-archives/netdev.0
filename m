From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-01-06
Date: Tue, 06 Jan 2015 13:15:48 +0100
Message-ID: <1420546548.1966.26.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here's just a single fix - a revert of a patch that broke the
p54 and cw2100 drivers (arguably due to bad assumptions there.)
Since this affects kernels since 3.17, I decided to revert for
now and we'll revisit this optimisation properly for -next.


Also -- happy New Year, and sorry about the genl issue :(

I'm still a bit confused about whether you wanted the pull request with
the text in the email or in the tag, or branch, or something - I
interpreted what you said to Kalle differently to what you said to me.
I've duplicated it for now :)

Thanks,
johannes

The following changes since commit 28a9bc68124c319b2b3dc861e80828a8865fd1ba:

  mac80211: free management frame keys when removing station (2014-12-17 14:00:17 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-01-06

for you to fetch changes up to 1e359a5de861a57aa04d92bb620f52a5c1d7f8b1:

  Revert "mac80211: Fix accounting of the tailroom-needed counter" (2015-01-05 10:33:46 +0100)

----------------------------------------------------------------
Here's just a single fix - a revert of a patch that broke the
p54 and cw2100 drivers (arguably due to bad assumptions there.)
Since this affects kernels since 3.17, I decided to revert for
now and we'll revisit this optimisation properly for -next.

----------------------------------------------------------------
Johannes Berg (1):
      Revert "mac80211: Fix accounting of the tailroom-needed counter"

 include/net/mac80211.h |  7 ++-----
 net/mac80211/key.c     | 12 +++++++++---
 2 files changed, 11 insertions(+), 8 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
