From: Stephen Hemminger <shemminger@osdl.org>
Subject: Please pull updated network drivers
Date: Mon, 8 May 2006 16:22:01 -0700
Message-ID: <20060508162201.57781b6f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61900 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750837AbWEHXV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 19:21:57 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48NLutH005889
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 16:21:56 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These fixes are for 2.6.17, please excuse my git learning curve.
I have about had it for today.

git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/netdev-2.6.git upstream

Daniel Drake:
      softmac: don't reassociate if user asked for deauthentication
      softmac: make non-operational after being stopped

David Woodhouse:
      bcm43xx: Fix access to non-existent PHY registers

Herbert Valerio Riedel:
      au1000_eth.c: use ether_crc() from <linux/crc32.h>

Jean Delvare:
      ieee80211: Fix A band channel count (resent)

Jens Osterkamp:
      spidernet: introduce new setting
      spidernet: enable support for bcm5461 ethernet phy

Michael Buesch:
      bcm43xx: fix iwmode crash when down
      bcm43xx: Fix array overrun in bcm43xx_geo_init

Sergei Shtylyov:
      Fix RTL8019AS init for Toshiba RBTX49xx boards

Stefano Brivio:
      bcm43xx: check for valid MAC address in SPROM

Stephen Hemminger:
      sky2: backout NAPI reschedule
      sky2: status irq hang fix
      sky2: tx ring index mask fix
      sky2: use mask instead of modulo operation
      sky2: edge triggered workaround enhancement
      sky2: dont write status ring
      sky2: synchronize irq on remove
      Add more support for the Yukon Ultra chip found in dual core
centino laptops. sky2: version 1.3
      Merge branch 'upstream-fixes' of
git://git.kernel.org/.../linville/wireless-2.6
