From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: rp_filter backward compatibility
Date: Tue, 31 Aug 2010 17:50:43 +0200
Message-ID: <4C7D24D3.8060200@6wind.com>
References: <4C7BCD62.3030805@6wind.com> <20100830.094726.212692387.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020500020400070508040001"
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48159 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab0HaPuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 11:50:55 -0400
Received: by wyb35 with SMTP id 35so8033533wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 08:50:54 -0700 (PDT)
In-Reply-To: <20100830.094726.212692387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020500020400070508040001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here is the (small) patch.

Regards,
Nicolas

David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Mon, 30 Aug 2010 17:25:22 +0200
> 
>> At least, one of this action should be done:
>>  - fixing help (Documentation/networking/ip-sysctl.txt is up to date)
> 
> This is the only option.

--------------020500020400070508040001
Content-Type: text/x-diff;
 name="0002-ipv4-minor-fix-about-RPF-in-help-of-Kconfig.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-ipv4-minor-fix-about-RPF-in-help-of-Kconfig.patch"

>From a2ea92449b7bfe3952d4714e13df00f5b8595c86 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 31 Aug 2010 17:47:42 +0200
Subject: [PATCH] ipv4: minor fix about RPF in help of Kconfig

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7c3a7d1..571f895 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -46,7 +46,7 @@ config IP_ADVANCED_ROUTER
 	  rp_filter on use:
 
 	  echo 1 > /proc/sys/net/ipv4/conf/<device>/rp_filter
-	   and
+	   or
 	  echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
 
 	  Note that some distributions enable it in startup scripts.
-- 
1.5.6.5


--------------020500020400070508040001--
