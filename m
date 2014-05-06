From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 0/3] Fixes to network device group configuration via rtnetlink
Date: Tue,  6 May 2014 18:13:14 +0300
Message-ID: <cover.1399388943.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:38245 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365AbaEFPQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:16:01 -0400
Received: from smtp10.mail.ru (smtp10.mail.ru [94.100.176.152])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id EA293114AEF26
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:13:55 +0400 (MSK)
Received: from [195.234.68.4] (port=41193 helo=tuxracer.skif.com.ua)
	by smtp10.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh3v-0004LE-MX
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:13:43 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this small patch series I present few fixes to the network device
group configuration via rtnetlink interface.

For more information on problems addressed, please see description
of each patch in the thread.

Sergey Popovich (3):
  rtnetlink: walk through all devs in netns safely on link params change
  rtnetlink: fix potential NULL pointer dereference
  rtnetlink: add IFLA_GROUP to ifla_policy

 net/core/rtnetlink.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

-- 
1.8.3.4
