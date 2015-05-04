From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-05-04
Date: Mon, 04 May 2015 13:02:09 +0200
Message-ID: <1430737329.2013.21.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

As I was sick last week this dragged out for a bit, but given we have
-rc2 out I figured I'd send you something sooner rather than later.

Let me know if there are any issues.

johannes


The following changes since commit 388f997620cb57372c494a194e9698b28cc179b8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-04-17 16:31:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-05-04

for you to fetch changes up to ff419b3f95ab7a97c5f72876b53f12a249dacc2a:

  mac80211: fix 90 kernel-doc warnings (2015-05-04 12:56:13 +0200)

----------------------------------------------------------------
We have only a few fixes right now:
 * a fix for an issue with hash collision handling in the
   rhashtable conversion
 * a merge issue - rhashtable removed default shrinking
   just before mac80211 was converted, so enable it now
 * remove an invalid WARN that can trigger with legitimate
   userspace behaviour
 * add a struct member missing from kernel-doc that caused
   a lot of warnings

----------------------------------------------------------------
Johannes Berg (3):
      mac80211: don't warn when stopping VLAN with stations
      mac80211: fix rhashtable conversion
      mac80211: enable hash table shrinking

Randy Dunlap (1):
      mac80211: fix 90 kernel-doc warnings

 include/net/mac80211.h  |  2 ++
 net/mac80211/iface.c    | 12 +++++++-----
 net/mac80211/sta_info.c | 19 ++++++++++++++++++-
 3 files changed, 27 insertions(+), 6 deletions(-)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
