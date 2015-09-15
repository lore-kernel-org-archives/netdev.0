From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: kernel 4.2 : "bridge vlan" command return empty result (works with
 kernel 4.1.3)
Date: Tue, 15 Sep 2015 19:39:22 +0200 (CEST)
Message-ID: <1167950469.57377315.1442338762965.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa <roopa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:53231 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbIORjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 13:39:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

since kernel 4.2, "bridge vlan" command return empty result.


kernel 4.1.3
------------
# bridge vlan
port	vlan ids
eth0	 1 PVID Egress Untagged
	 90
	 91
	 92
	 93
	 94
	 95
	 96
	 97
	 98
	 99
	 100

vmbr0	 1 PVID Egress Untagged
	 94



kernel 4.2  
----------------
# bridge vlan
port	vlan ids



Note that vlans are correctly working,it seem that is just the display.

tcpdump -e -i vmbr0

19:38:08.005055 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 339613, win 5523, length 0
19:38:08.007730 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 342145, win 5568, length 0
19:38:08.010977 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 344677, win 5614, length 0
19:3
