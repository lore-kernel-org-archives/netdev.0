From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [iproute2 RFC v2 0/2] Add option to ip link to set VF privileges
Date: Tue, 14 Feb 2012 13:26:34 -0600
Message-ID: <20120214192634.GA14320@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759984Ab2BNT1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:27:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ip link option to change the privilege level for the specified VF.

Example usage:-

If the current Privilege of the VF is 0x86:

To add VLAN privilege to the VF,
   ip link set ethX vf 0 privilege 0xC6

To add VLAN & MAC privilege to the VF,
   ip link set ethX vf 0 privilege 0xE6

To give just default privileges to the VF
   ip link set ethX vf 0 privilege 0x1

o/p of the *new* ip link show command:
ip link show eth2
9: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:00:c9:ef:7c:9a brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 00:00:c9:f6:b0:4d, privilege 0x1
