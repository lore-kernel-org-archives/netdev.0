From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe and mac-vlans problem
Date: Thu, 29 Apr 2010 15:27:39 -0700
Message-ID: <4BDA07DB.8020206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43733 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758851Ab0D3Rdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

We are seeing a strange problem with mac-vlans on top of an 82599 NIC (ixgbe)
on a 2.6.31.y (plus patches) kernel.

Basically, we create 50 mac-vlans, with sequential MAC addresses and sequential
IP addresses, and set up ip rules properly.

The issue is that only 10 or so of the mac-vlans receive other than
broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.

If we manually turn on PROMISC mode on the physical ixgbe interface,
then everything works properly.  I'm guessing the ixgbe NIC must
have some filters that mac-vlan is trying to enable w/out turning on
full PROMISC mode.  Is there any easy way to debug these filters
to see if they are being properly configured?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

