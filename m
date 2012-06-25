From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 0/3 v3 resend] 6lowpan: minor fixes
Date: Mon, 25 Jun 2012 17:49:00 +0400
Message-ID: <1340632143-27794-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49406 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717Ab2FYNwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:52:18 -0400
Received: by bkcji2 with SMTP id ji2so3150469bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 06:52:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I sent this set several weeks ago and seems that it was missed
(or please let me know if there was a reason).

this is the 3-rd version of the patches.
Changes since v2:
 - Removed WARN_ON() and BUG() from skb fetch methods. That wasn't a good idea
   to crash kernel by such an unsignificant issue.
 - Added new patch (I've decided to add it here just to keep all the 6lowpan
   related code together)

Could you please review this set?

Thank you for your time!

With best regards,
Alexander Smirnov

Alexander Smirnov (3):
  6lowpan: read data from skb safely
  6lowpan: fix hop limit compression
  6lowpan: remove excessive argument in pr_debug

 net/ieee802154/6lowpan.c |  163 ++++++++++++++++++++++------------------------
 1 files changed, 78 insertions(+), 85 deletions(-)

--
1.7.2.3
