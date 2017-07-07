From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-07-07
Date: Fri,  7 Jul 2017 11:29:01 +0200
Message-ID: <20170707092902.14834-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36732 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750882AbdGGJ3J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 05:29:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Just got a set of fixes in from Jouni/QCA, all netlink validation
fixes. I assume they ran some kind of checker, but I don't know
what kind :)

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 4b153ca989a9bf61f622ded32e1d689df88edaa5:

  Merge tag 'mac80211-for-davem-2017-06-16' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2017-06-19 00:03:51 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-07-07

for you to fetch changes up to d7f13f7450369281a5d0ea463cc69890a15923ae:

  cfg80211: Validate frequencies nested in NL80211_ATTR_SCAN_FREQUENCIES (2017-07-07 11:24:31 +0200)

----------------------------------------------------------------
netlink validation fixes for nl80211

----------------------------------------------------------------
Srinivas Dasari (4):
      cfg80211: Check if PMKID attribute is of expected size
      cfg80211: Check if NAN service ID is of expected size
      cfg80211: Define nla_policy for NL80211_ATTR_LOCAL_MESH_POWER_MODE
      cfg80211: Validate frequencies nested in NL80211_ATTR_SCAN_FREQUENCIES

 net/wireless/nl80211.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)
