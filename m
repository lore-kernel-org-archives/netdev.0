From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Loop detected - calling function from different modules
Date: Thu, 31 Aug 2006 11:57:46 +0200
Message-ID: <1157018266.3065.17.camel@ux156>
References: <BAY101-F33A13C37EC4876E17B74C0AB3F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42411 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750720AbWHaJ5L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 05:57:11 -0400
To: Frank Schneider <twodipu@hotmail.com>
In-Reply-To: <BAY101-F33A13C37EC4876E17B74C0AB3F0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank,


> Any suggestions to do that please ?

d80211 has a hardware definition struct that is registered by the driver
and contains a callback that is called for each frame. This is the
direction you should take as well:

   hard_start_xmit (generic code)
calls
   hardware_xmit (your module code, e.g. in a struct wlan_device)

johannes
