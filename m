From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-04-14
Date: Thu, 14 Apr 2016 09:27:17 +0200
Message-ID: <1460618838-5819-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42057 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044AbcDNH10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 03:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Since I didn't get anything else, and this has been pending for a week,
here's the other part of the nl80211 socket problem fix (the netlink
family URELEASE was the first part.)

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 30d237a6c2e9be1bb816fe8e787b88fd7aad833b:

  Merge tag 'mac80211-for-davem-2016-04-06' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2016-04-08 16:41:28 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-04-14

for you to fetch changes up to 8f815cdde3e550e10c2736990d791f60c2ce43eb:

  nl80211: check netlink protocol in socket release notification (2016-04-12 15:39:06 +0200)

----------------------------------------------------------------
This has just the single fix from Dmitry Ivanov, adding the missing
netlink notifier family check to avoid the socket close DoS problem.

----------------------------------------------------------------
Dmitry Ivanov (1):
      nl80211: check netlink protocol in socket release notification

 net/wireless/nl80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
