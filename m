From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Management packet 0x70 -> connection broken
Date: Sun, 28 May 2006 13:33:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.60.0605281328470.4491@poirot.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:44000 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1750713AbWE1Ld2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 07:33:28 -0400
Received: from lyakh (helo=localhost)
	by poirot.grange with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FkJWa-0002Yk-00
	for <netdev@vger.kernel.org>; Sun, 28 May 2006 13:33:36 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

Using the zd1211rw driver on a ppc under Sarge, 2.6.17-rc2 with some 
ieee80211 / softmac patches I get

ieee80211: eth1: Unknown management packet: 112

and then the connection was broken:-( What is the 0x70 packet? Have been 
using the original zd1211 vendor-based driver before, probably, these 
packets also were seen, but the connection didn't break. I can put a debug 
in the original driver to see what happens when these packets arrive. 
Basically they just ignore them as well as ieee80211 now, but without 
fatal consequences... Using openvpn over eth1 if it matters.

Not subscribed, please cc.

Thanks
Guennadi
---
Guennadi Liakhovetski
