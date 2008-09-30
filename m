From: Brian Haley <brian.haley@hp.com>
Subject: Can't build net-next-2.6 without CONFIG_MAC80211_MESH
Date: Tue, 30 Sep 2008 10:35:54 -0400
Message-ID: <48E2394A.3010707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:6665 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbYI3Of5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:35:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry if this has been discussed/fixed already, but I just noticed last 
night I couldn't build net-next-2.6:

Kernel: arch/x86/boot/bzImage is ready  (#71)
ERROR: "mpp_path_lookup" [net/mac80211/mac80211.ko] undefined!
ERROR: "mpp_path_add" [net/mac80211/mac80211.ko] undefined!

These are defined in net/mac80211/mesh_pathtbl.c, but being called from 
rx.c and tx.c, but I'm not building the mesh files:

--> grep CONFIG_MAC80211 .config
CONFIG_MAC80211=m
CONFIG_MAC80211_RC_PID=y
CONFIG_MAC80211_RC_DEFAULT_PID=y
CONFIG_MAC80211_RC_DEFAULT="pid"
# CONFIG_MAC80211_MESH is not set
# CONFIG_MAC80211_LEDS is not set
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_DEBUG_MENU is not set

make oldconfig didn't make any changes, so I think the config is valid.

-Brian
