From: Franchoze Eric <franchoze@yandex.ru>
Subject: shape traffic on tun interfaces
Date: Sun, 01 Aug 2010 02:09:30 +0400
Message-ID: <301941280614170@web105.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward9.mail.yandex.net ([77.88.61.48]:55152 "EHLO
	forward9.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab0GaWJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 18:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do we have any interface to shape traffic per destination IP? The standrad HTB shapes it per device, which is not suitable for case if limitation required per destination IP. For example openvpn server which servers about 3000 clients and has 10 internal tun interfases (tun0-tun9). Of course it is possible to do it on application level (vpn), but I would prefer any system solution for this.  iptables with --limit does not work in this case because it will simple drop packets. Did somebody work on such task?

Eric.
