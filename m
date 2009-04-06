From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: zero features for a vlan over bond
Date: Mon, 6 Apr 2009 16:00:12 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:26703 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754403AbZDFNAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 09:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Using vconfig and the 8021q modules I have created a vlan device over a
bond (e.g bond0.4001 over bond0 which is over eth0,eth1) - but for some
reason the vlan device has no features - any idea what may be the reason
for that? below is the flags/features matrix (eth0/1 are igb, 2.6.29)

device		flags	features
================================
bond0.4001	0x1403	0x0
bond0		0x1403	0x1113a9
eth0/1		0x1803	0x111ba9

Or.
