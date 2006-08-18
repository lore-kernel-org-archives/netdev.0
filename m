From: Johannes Berg <johannes@sipsolutions.net>
Subject: [clarification request] ieee80211_tx_control.pkt_type
Date: Fri, 18 Aug 2006 13:41:57 +0200
Message-ID: <1155901317.22520.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46304 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030204AbWHRLmG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 07:42:06 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I was pondering the ieee80211_tx_control type and don't see anyone using
the pkt_type field. d80211 makes great effort to have it correct, but no
driver uses it.

Hence, my question: What is the purpose of this field? Under what
circumstances would a driver have to know this? Especially considering
that it's only "normal" vs. "probe response"...

johannes
