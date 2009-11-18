From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH iproute2] ip: Add support for setting MAC and VLAN
 on hardware queues
Date: Wed, 18 Nov 2009 10:07:28 -0800 (PST)
Message-ID: <20091118.100728.91511216.davem@davemloft.net>
References: <20091117215432.15195.94504.stgit@localhost.localdomain>
	<20091117140641.7f8c8ac0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, mitch.a.williams@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932159AbZKRSHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:07:12 -0500
In-Reply-To: <20091117140641.7f8c8ac0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Nov 2009 14:06:41 -0800

> On Tue, 17 Nov 2009 13:55:07 -0800
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> From: Williams, Mitch A <mitch.a.williams@intel.com>
>> 
>> This patch adds support to the "ip" tool for setting the MAC address and
>> VLAN filter for hardware device queues. This is most immediately useful for
>> SR-IOV; for VF devices to be usable in the real world, the hypervisor or VM
>> manager must be able to set these parameters before the VF device is
>> assigned to any VM.
>> 
>> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Is there anything to avoid prevent this from being misused by users who
> are doing multiqueue. Maybe we need equivalent of "mounted" flag that block
> devices have?

It's a privileged config operation as far as I can tell.

Given that, what could we possibly need to protect?

This stuff looks basically fine to me.

