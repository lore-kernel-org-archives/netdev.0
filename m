From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: iproute2: ip-link: fix parsing inconsistencies
Date: Wed, 11 Dec 2013 14:24:53 +0200
Message-ID: <3582398.gq1TiRX59v@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.mail.ru ([94.100.176.177]:36856 "EHLO smtp24.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172Ab3LKM3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 07:29:51 -0500
Received: from [2a01:6d80:103:13::c3ea:4404] (port=48238 helo=tuxracer.localnet)
	by smtp24.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1VqivF-00055d-6w
	for netdev@vger.kernel.org; Wed, 11 Dec 2013 16:29:49 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes some inconsistencies in ip-link(8).
Each patch supplied with description of problem it addresses.

Sergey Popovich (2):
  Initialize arguments to iplink_parse() by default
  Handle netdev group for veth peer too

 ip/iplink.c    |    9 +++------
 ip/link_veth.c |    3 +++
 2 files changed, 6 insertions(+), 6 deletions(-)

-- 
1.7.10.4
