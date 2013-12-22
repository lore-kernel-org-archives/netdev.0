From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 0/2] tun: add the RFS support
Date: Sun, 22 Dec 2013 18:54:30 +0800
Message-ID: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:58810 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab3LVKyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Dec 2013 05:54:50 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Sun, 22 Dec 2013 05:54:49 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 28CF16E8040
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 05:54:44 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBMAslbJ9044400
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 10:54:47 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBMAskEn002092
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 05:54:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

HI, folks

Since Tom Herbert's hash related patchset was modified and got merged,
his pachset about adding support for RFS on tun flows also need to get
adjusted accordingly. I tried to update them, and before i will start
to do some perf tests, i hope to get one correct code base, so it's time
to post them out now. Any constructive comments are welcome, thanks.


Tom Herbert (2):
  net: Allow setting sock flow hash without a sock
  tun: Add support for RFS on tun flows

 drivers/net/tun.c  |   37 +++++++++++++++++++++++++++++++++++--
 include/net/sock.h |   18 ++++++++++++++----
 2 files changed, 49 insertions(+), 6 deletions(-)

-- 
1.7.6.5
