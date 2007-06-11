From: David Miller <davem@davemloft.net>
Subject: [GIT]: net-2.6.23 tree available
Date: Sun, 10 Jun 2007 18:17:04 -0700 (PDT)
Message-ID: <20070610.181704.73383002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758368AbXFKBQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 21:16:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D5C33510001
	for <netdev@vger.kernel.org>; Sun, 10 Jun 2007 18:17:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Get it while it's hot:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.23.git

We have the qdisc_restart cleanup from Jama, some TIPC work
from Allan Stephens and co., and Patrick's rtnl_link work.

Also we have the removal of that multipath cached crap, and
eth_copy_and_sum() which hasn't summed anything in nearly
a decade.

So go fetch a double double, sit back, and enjoy.

Linux Networking.  Always Fresh!

Allan Stephens (3):
      [TIPC]: Improved support for Ethernet traffic filtering
      [TIPC]: Use standard socket "not implemented" routines
      [TIPC]: Optimize stream send routine to avoid fragmentation

David S. Miller (2):
      [IPV4]: The scheduled removal of multipath cached routing support.
      [NET]: Kill eth_copy_and_sum().

Herbert Xu (1):
      [TCPv4]: Improve BH latency in /proc/net/tcp

Jamal Hadi Salim (1):
      [NET_SCHED]: Cleanup readability of qdisc restart

Larry Finger (1):
      [MAC80211]: Add support for SIOCGIWRATE ioctl

Patrick McHardy (17):
      [NET]: Mark struct net_device * argument to netdev_priv const
      [RTNETLINK]: Split up rtnl_setlink
      [RTNETLINK]: Link creation API
      [DUMMY]: Use dev->stats
      [DUMMY]: Keep dummy devices on list
      [DUMMY]: Use rtnl_link API
      [IFB]: Keep ifb devices on list
      [IFB]: Use rtnl_link API
      [VLAN]: Convert name-based configuration functions to struct netdevice *
      [VLAN]: Move some device intialization code to dev->init callback
      [VLAN]: Move vlan_group allocation to seperate function
      [VLAN]: Split up device checks
      [VLAN]: Move device registation to seperate function
      [VLAN]: Return proper error codes in register_vlan_device
      [VLAN]: Use 32 bit value for skb->priority mapping
      [VLAN]: Keep track of number of QoS mappings
      [VLAN]: Use rtnl_link API

