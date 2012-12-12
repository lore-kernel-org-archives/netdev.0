From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Wed, 12 Dec 2012 12:05:41 -0800
Message-ID: <20121212120541.72ba1ba9@nehalam.linuxnetplumber.net>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40703 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212Ab2LLUG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 15:06:58 -0500
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 15:01:06 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

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

My concern is that all older configurations must continue to work.
Is it still unchanged if a vlan device is added to the bridge, or vlan is
configured on an ethernet that has been added to the bridge?
