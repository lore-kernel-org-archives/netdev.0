From: David <david@unsolicited.net>
Subject: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Sun, 18 Nov 2007 19:00:12 +0000
Message-ID: <47408BBC.6040608@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns01.unsolicited.net ([69.10.132.115]:51282 "EHLO
	ns01.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbXKRT3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 14:29:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm (very) far from being firewall configuration expert, but I'm seeing
a consistent kernel panic when the following rule is triggered.

    iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
5061 --to-ports 5060

(I'm trying to redirect an alternate port to a SIP server)

Am I just being very stupid, or is there something I'm not seeing here?

Thanks
David

