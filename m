From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-10-09
Date: Mon,  9 Oct 2017 09:40:12 +0200
Message-ID: <20171009074013.1979-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.63.242]:34704 "EHLO
        sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751257AbdJIHkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 03:40:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The QCA folks found another netlink problem - we were missing validation
of some attributes. It's not super problematic since one can only read a
few bytes beyond the message (and that memory must exist), but here's the
fix for it.

I thought perhaps we can make nla_parse_nested() require a policy, but
given the two-stage validation/parsing in regular netlink that won't work.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 9f775ead5e570e7e19015b9e4e2f3dd6e71a5935:

  l2tp: fix l2tp_eth module loading (2017-10-01 22:35:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-10-09

for you to fetch changes up to ad670233c9e1d5feb365d870e30083ef1b889177:

  nl80211: Define policy for packet pattern attributes (2017-10-04 14:39:21 +0200)

----------------------------------------------------------------
Just a single fix for a missing netlink attribute validation.

----------------------------------------------------------------
Peng Xu (1):
      nl80211: Define policy for packet pattern attributes

 net/wireless/nl80211.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)
