From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: netconsole breaks netpoll on bridge
Date: Mon, 16 Jun 2014 14:51:58 +0200
Message-ID: <539EE86E.6030806@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: stephen@networkplumber.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:34863 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbaFPM5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 08:57:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i'm using a vanilla 3.10.43 kernel and netconsole on top of a bridge.

netconsole is used with vmbr0 (bridge) which is on top of bond0.

If i want to add another bridge to vmbr0 is fails as long as netconsole
is in use.

# brctl addif vmbr0 fwpr2004p0
can't add fwpr2004p0 to bridge vmbr0: Unknown error 524

Kernel output:
netpoll: (null): fwpr2004p0 doesn't support polling, aborting

If i do rmmod netconsole - everything is working fine again.

Greets,
Stefan
