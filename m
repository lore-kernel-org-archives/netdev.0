From: <Narendra_K@Dell.com>
Subject: Generic interface to make physical port number used by a netdevice
 available to user space
Date: Wed, 22 May 2013 13:24:15 +0530
Message-ID: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:62970 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab3EVIGN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 04:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It is useful to know if network interfaces from NIC partitions 'map to/ use the'
same physical port. For example,  when creating bonding in fault tolerance mode,
if two network interfaces map to/use the same physical port, it might not have the
desired result. This information is not available today in a standard format or
it is not present.  If this information can be made available in a generic  way
to user space, tools such as NetworkManager or Libteam  or Wicked can make smarter
bonding decisions (such as warn users when setting up configurations which will
not have desired effect).

The requirement is to have a generic interface using which kernel/drivers can
provide information/hints to user space about the physical port number used by
a network interface.

While looking for already existing generic facility, 'dev_id' sysfs attribute
seemed relevant. Looking into the sources seemed to indicate that majority of 
the drivers do not set it and it could be interpreted differently.

It would be great to know list's thoughts on  'dev_id' being used as the interface
to make the physical port number information used by netdevice available to user
space or do we need a new sysfs attribute for the same.

Note: I think in the scenario of SRIOV VF devices assigned to guest and being
bonded, additional information would be needed to differentiate the network
controller in the host.  But I suppose it is a different problem than this.

References to related discussions:
1. [PATCH net-next] bnx2x: Add Nic partitioning mode (57712)
http://marc.info/?l=linux-netdev&m=129098288709528&w=2
2. [PATCH net-next] bonding: Support for multi function NIC devices
http://marc.info/?l=linux-netdev&m=134240221118594&w=2

Thank you,

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
