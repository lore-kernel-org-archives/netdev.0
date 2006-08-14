From: Johannes Berg <johannes@sipsolutions.net>
Subject: ieee80211_set_encryption...
Date: Mon, 14 Aug 2006 10:16:53 +0200
Message-ID: <44E03175.6070804@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57988 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751813AbWHNIQ5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:16:57 -0400
To: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

... is a big mess.

What's with all the comments saying 'maybe with blabla hardware that can 
be done in hw but disable here now' etc? Can't we just have a 'please 
decide' callback in the driver that tells us whether this can be done in 
hw or sw?

Or how about no_tkip_wmm_hwaccel? That seems pretty weird too.

I do realize that key management in the face of wpa2 and similar is 
difficult, but this seems overly complex. Comments?

johannes

