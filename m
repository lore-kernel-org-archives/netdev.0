From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 0/2] Add missing file close
Date: Fri, 14 Aug 2015 02:56:51 +0000
Message-ID: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9809 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbbHNCxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 22:53:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds some missing close() calls.

Zhang Shengju (2):
  libs: close file in netns_switch()
  netns: add missing file close

 ip/ipnetns.c    | 5 +++++
 lib/namespace.c | 6 +++---
 2 files changed, 8 insertions(+), 3 deletions(-)

-- 
1.8.3.1
