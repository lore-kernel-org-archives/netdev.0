From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 15:28:58 -0500 (EST)
Message-ID: <20121213.152858.1666583339993031731.davem@davemloft.net>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, mst@redhat.com,
	john.r.fastabend@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756967Ab2LMU3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 15:29:00 -0500
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 12 Dec 2012 15:01:06 -0500

> This series of patches provides an ability to add VLANs to the bridge
> ports.  This is similar to what can be found in most switches.  The bridge
> port may have any number of VLANs added to it including vlan 0 priority tagged 
> traffic.  When vlans are added to the port, only traffic tagged with particular
> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
> entries and become part of the lookup.  This way we correctly identify the FDB
> entry.
> 
> A single vlan may also be designated as untagged.  Any untagged traffic
> recieved by the port will be assigned to this vlan.  Any traffic exiting
> the port with a VID matching the untagged vlan will exit untagged (the
> bridge will strip the vlan header).  This is similar to "Native Vlan" support
> available in most switches.
> 
> The default behavior ofthe bridge is unchanged if no vlans have been
> configured.

FWIW I've reviewed these changes and I like them a lot.

They resolve a real ambiguity, and using ebtables as a reason these
changes should not be applied amounts to a scarecrow.
