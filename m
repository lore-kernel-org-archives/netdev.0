From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next PATCH 0/2] iovnl netlink ops + enic dynamic vnics
Date: Mon, 19 Apr 2010 14:35:31 -0700
Message-ID: <20100419213531.GG5715@x200.localdomain>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632Ab0DSVff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 17:35:35 -0400
Content-Disposition: inline
In-Reply-To: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Scott Feldman (scofeldm@cisco.com) wrote:
> Patch 1/2 adds new I/O Virtualization netlink ops:
> 
>   IOV netlink (IOVNL) adds I/O Virtualization control support to a master
>   device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
>   control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
>   design allows for the case where master and slave are the
>   same netdev interface.
> 
>   The ops currently defined are:
>   	set_mac_vlan: set mac+vlan on VF
> 	set_port_profile: set port-profile on VF
> 	unset_port_profile: unset port-profile on VF
> 
> Patch 2/2 adds IOV netlink ops support to enic dynamic vnics:
> 
>   Add enic iovnl ops to support setting port-profile for dynamic vnics.  Enic
>   dynamic vnics are just like normal enic eth vnics except dynamic vnics require
>   an extra configuration step to assign a port-profile identifier to the
>   interface before the interface is useable. Once assigned, link comes up
>   on the interface and is ready for I/O.  The port-profile is used to configure
>   the network port assigned to the interface.  The network port configuration
>   includes VLAN membership, QoS policies, and port security settings typical
>   of a data center network.

Note that while these just enable enic, the framework should be generic
enough for other drivers and can deliver all the way to userspace daemon
for the case of VSI Discovery Protocol.

thanks,
-chris
