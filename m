From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/5] d80211: better fragmentation handling
Date: Mon, 12 Jun 2006 21:16:01 +0200 (CEST)
Message-ID: <20060612211454.409884000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:167 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932086AbWFLTOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:14:48 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patches allow proper handling of situation when hw queue gets
filled up while sending 802.11 fragments.

This breaks drivers; an example how to fix them is in second patch. Also,
get_tx_stats callback is optional now.

-- 
Jiri Benc
SUSE Labs
