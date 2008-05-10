From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/4] atl1: fix suspend, resume, wake-on-lan
Date: Fri,  9 May 2008 22:12:05 -0500
Message-ID: <1210389129-3868-1-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	csnook@redhat.com, pelle@dsv.su.se
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([207.115.11.51]:58161 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758782AbYEJDMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 23:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These patches fix suspend, resume, and wake-on-lan. Please merge for 2.6.27.

Diffstat

 drivers/net/atlx/atl1.c |  157 +++++++++++++++++++++++++++++------------------
 drivers/net/atlx/atl1.h |    2 +-
 drivers/net/atlx/atlx.c |    2 +-
 drivers/net/atlx/atlx.h |    7 ++-
 4 files changed, 105 insertions(+), 63 deletions(-)

