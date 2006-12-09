From: Pavel Roskin <proski@gnu.org>
Subject: Please make CONFIG_CFG80211 harder to enable
Date: Sat, 09 Dec 2006 03:48:43 -0500
Message-ID: <1165654123.2816.29.camel@portland.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:1612 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936383AbWLIIsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 03:48:51 -0500
Received: from [192.168.1.102] (c-71-230-131-166.hsd1.pa.comcast.net [71.230.131.166])
	by relay.cesmail.net (Postfix) with ESMTP id 5F681618F25
	for <netdev@vger.kernel.org>; Sat,  9 Dec 2006 03:48:50 -0500 (EST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Somebody please mark CONFIG_CFG80211 in wireless-dev.git as
experimental/broken/incomplete/whatever.  Not only doesn't it work, but
it also breaks Wireless Extensions if enabled, even if CONFIG_D80211 is
disabled.

Driver developers should know that if they enable CONFIG_CFG80211 they
won't be able to debug their drivers effectifely; they'll have to fix
cfg80211 first.

-- 
Regards,
Pavel Roskin
