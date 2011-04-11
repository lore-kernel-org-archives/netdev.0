From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: igmp_max_memberships and CONFIG_IP_MULTICAST
Date: Mon, 11 Apr 2011 21:34:21 +0200
Message-ID: <OF8B112606.401AF255-ONC125786F.006B302C-C125786F.006B840C@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:51391 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab1DKTk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 15:40:27 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id E835225803D
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 21:34:22 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Why is igmp_max_memberships hidden behind CONFIG_IP_MULTICAST?

I am running Quagga(OSPF) without CONFIG_IP_MULTICAST and ran into
this limit. Now I need to increase it but then I find it is hidden behind
CONFIG_IP_MULTICAST. Is there a reason it is hidden?

 Jocke

