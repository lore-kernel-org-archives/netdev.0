From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/3] vxlan: IPv6 fill_metadata_dst support
Date: Wed,  2 Dec 2015 19:12:07 +0100
Message-ID: <cover.1449079592.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755017AbbLBSMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 13:12:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds IPv6 support to ndo_fill_metadata_dst in vxlan together with
restructuring to avoid duplicate code.

Jiri Benc (3):
  vxlan: consolidate output route calculation
  vxlan: move IPv6 outpute route calculation to a function
  vxlan: support ndo_fill_metadata_dst also for IPv6

 drivers/net/vxlan.c | 140 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 91 insertions(+), 49 deletions(-)

-- 
1.8.3.1
