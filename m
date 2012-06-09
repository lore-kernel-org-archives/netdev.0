From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v3 0/3] 6lowpan fixes
Date: Sat,  9 Jun 2012 19:13:06 +0400
Message-ID: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44455 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731Ab2FIPSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 11:18:42 -0400
Received: by weyu7 with SMTP id u7so1173354wey.19
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 08:18:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

this is the 3-rd version of the patches.
Changes since v2:
 - Removed WARN_ON() and BUG() from skb fetch methods. That wasn't a good idea
   to crash kernel by such an unsignificant issue.
 - Added new patch (I've decided to add it here just to keep all the 6lowpan
   related code together)

Could you please review this set?

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
