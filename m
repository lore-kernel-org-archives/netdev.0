From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: Can I limit number of rx queues for igb (and other Intel
 drivers)?
Date: Mon, 21 Jun 2010 16:35:31 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318FD7874B40@orsmsx508.amr.corp.intel.com>
References: <4C1BF5AA.8010209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16270 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758065Ab0FUXfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 19:35:34 -0400
In-Reply-To: <4C1BF5AA.8010209@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: netdev-owner@vger.kernel.org 
>[mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Greear
>Sent: Friday, June 18, 2010 3:40 PM
>To: NetDev
>Subject: Can I limit number of rx queues for igb (and other 
>Intel drivers)?
>
>I'm using pktgen to send a stream of packets with varying 
>source and destination
>IP addresses.  It appears that the fancy rx logic of the NIC 
>(I'm using igb for this test)
>causes the received packets to appear on random rx queues and 
>so be received out
>of order in the network core.
>
>I do not see the out-of-order issue when using a single 
>source/dest IP address
>for the pktgen packets.
>
>So, is there a way to tell igb to use only a single rx queue?
>
>Thanks,
>Ben
>
>-- 
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Hello,

There is not a way to tell igb to use a single queue and ethtool does not currently have a way to do this.

We also maintain an out of kernel version of the driver at SourceForge that has module parameters to do this.  

If you need to do this with the kernel version, we'd need to modify ethtool to be able to do this.

Thanks,

Carolyn Wyborny
Carolyn.wyborny@intel.com