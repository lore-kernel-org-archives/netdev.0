From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Thu, 23 Jul 2009 14:14:52 +0300
Message-ID: <4A68462C.1080709@Voltaire.com>
References: <1248191263.18195.49.camel@lb-tlvb-eilong> <4A683F83.1060701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:55506 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751965AbZGWLPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 07:15:03 -0400
In-Reply-To: <4A683F83.1060701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> vlan_features doesn't need to be updated, the resulting dev->features
> of the VLAN device is computed as the intersection of dev->features
> and dev->vlan_features.

I'm not sure to follow, do you claim that the patches to bnx2x and bonding aren't needed to make vlans set on top of such devices to support these features?

For example, on two 2.6.30 systems I have here, where one uses Intel/igb and the second uses Broadcom/tg3 I can see that vlan devices on top of igb have features while those on top of tg3 has none


2.6.30/igb/8021q
# cat /sys/class/net/eth1/features
0x114bb3
# cat /sys/class/net/eth1.4004/features
0x110803


2.6.30/tg3/8021q
# cat /sys/class/net/eth1/features
0x109a3
# cat /sys/class/net/eth1.4001/features
0x0



Or.
