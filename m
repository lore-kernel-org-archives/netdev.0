From: Jan Engelhardt <jengelh@medozas.de>
Subject: multicast with multiple devices
Date: Mon, 26 May 2008 18:46:00 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805261844210.19084@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:40002 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbYEZQqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 12:46:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id 7D2591D106E87
	for <netdev@vger.kernel.org>; Mon, 26 May 2008 18:46:00 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


directing multicast traffic to a specific interface is an easy job, as in
	ip r a multicast 224.168.17.3/32 dev eth2
but what if both eth1 and eth2 have multicast listeners with this 
destination address? Adding another route does not change anything 
because the kernel only finds the first one. Ideas on how this can be 
addressed?


Jan
