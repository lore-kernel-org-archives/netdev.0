From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2 0/2] vxlan: IPv6 fill_metadata_dst support
Date: Thu,  3 Dec 2015 11:41:21 +0100
Message-ID: <cover.1449139112.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712AbbLCKlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 05:41:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds IPv6 support to ndo_fill_metadata_dst in vxlan. The IPv4 part
needs some restructuring to avoid duplicate code, this will be sent as
a separate patch targeting net-next.

Jiri Benc (2):
  vxlan: move IPv6 outpute route calculation to a function
  vxlan: support ndo_fill_metadata_dst also for IPv6

 drivers/net/vxlan.c | 70 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 58 insertions(+), 12 deletions(-)

-- 
1.8.3.1
