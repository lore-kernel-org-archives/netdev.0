From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New stuff in wireless-dev, wireless developers please pull...
Date: Fri, 03 Nov 2006 10:06:22 +0100
Message-ID: <1162544782.2923.15.camel@ux156>
References: <20061103043024.GF2989@tuxdriver.com>
	 <200611030142.09303.flamingice@sourmilk.net>
	 <1162543492.2923.6.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48806 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752644AbWKCJFT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 04:05:19 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <1162543492.2923.6.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It doesn't seem to compile on my system:
> 
> net/built-in.o: In function `iw_send_thrspy_event':
> wext-old.c:(.text+0x67672): undefined reference to `wireless_send_event'

Uh, common is missing. Adjust net/wireless/Makefile like this:

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I'd be surprised if that patch applies. I generated it by hand :P
What would be cool if I could go to gitweb, edit the file and get a diff
out :) gitwiki.

--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -12,6 +12,6 @@
 
 # this needs to be compiled in...
 obj-$(CONFIG_CFG80211_WEXT_COMPAT) += wext-compat.o
-obj-$(CONFIG_CFG80211_WEXTNL_COMPAT)$(CONFIG_NET_WIRELESS_RTNETLINK) += wext-common.o
+obj-$(CONFIG_CFG80211_WEXTNL_COMPAT)$(CONFIG_NET_WIRELESS) += wext-common.o
 obj-y += $(obj-yy) $(obj-yn) $(obj-ny)


