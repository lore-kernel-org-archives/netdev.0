From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 00/29] Add support for the Intel FM10000
 Ethernet Switch Host Interface
Date: Mon, 22 Sep 2014 15:17:50 -0400 (EDT)
Message-ID: <20140922.151750.1374374207690364454.davem@davemloft.net>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
	<1411410964.2513.1.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, nhorman@redhat.com,
	netdev@vger.kernel.org, john.fastabend@gmail.com,
	matthew.vick@intel.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbaIVTRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:17:53 -0400
In-Reply-To: <1411410964.2513.1.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 22 Sep 2014 11:36:04 -0700

> On Sat, 2014-09-20 at 19:45 -0400, Alexander Duyck wrote:
>> This patch series adds support for the FM10000 Ethernet switch host
>> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet switch
>> supporting both Ethernet ports and PCI Express host interfaces.  The fm10k
>> driver provides support for the host interface portion of the switch, both
>> PF and VF.
>> 
>> As the host interfaces are directly connected to the switch this results in
>> some significant differences versus a standard network driver.  For example
>> there is no PHY or MII on the device.  Since packets are delivered directly
>> from the switch to the host interface these are unnecessary.  Otherwise most
>> of the functionality is very similar to our other network drivers such as
>> ixgbe or igb.  For example we support all the standard network offloads,
>> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
>> 
>> ---
> 
> Dave, if it makes it easier on you, I can add Alex's series of patches
> to my net-next tree for you to pull.  Just give me an hour or so so that
> I can update my net-next and push his patches up to my tree.

Yeah, could you please do that?

Thanks.
