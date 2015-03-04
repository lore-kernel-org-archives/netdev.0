From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH iproute2 net-next 0/2] Extend ip address command to enable multicast group join/leave on IP level
Date: Wed,  4 Mar 2015 10:30:08 -0800
Message-ID: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38929 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759000AbbCDSrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:47:23 -0500
Received: by pdjy10 with SMTP id y10so59557698pdj.6
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:47:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extends "ip address" command with autojoin keyword

Madhu Challa (2):
  Header rebase for IFA_F_MCAUTOJOIN
  Enable configuring multicast group join / leave at IP level.

 include/linux/if_addr.h |  1 +
 ip/ipaddress.c          | 26 +++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

-- 
1.9.1
