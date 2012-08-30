From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 30 Aug 2012 15:37:24 +0300
Message-ID: <20120830123724.GE20228@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092Ab2H3MgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 08:36:04 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7UCa4Og023345
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 08:36:04 -0400
Content-Disposition: inline
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 03:29:50PM -0400, Vlad Yasevich wrote:
> This series of patches provides an ability to add VLAN IDs to the bridge
> ports.  This is similar to what can be found in most switches.  The bridge
> port may have any number of VLANs added to it including vlan 0 for untagged
> traffic.  When vlans are added to the port, only traffic tagged with particular
> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
> entries and become part of the lookup.  This way we correctly identify the FDB
> entry.
> 
> There are still pieces missing.  I don't yet support adding a static fdb entry
> with a particular vlan.  There is no netlink support for carrying a vlan id.
> 
> I'd like to hear thoughts of whether this is usufull and something we should
> persue.
> 
> The default behavior ofthe bridge is unchanged if no vlans have been
> configured.

Overall the feature looks good, I can think of some uses
for it - for example, it could become useful for VMs if
we add support to tap essentially stripping tags in Xmit but maybe you
could be more explicit about what you have in mind?
Do you plan to add tap support as well?
Also - what tool support do you plan?

I also found some coding style issues and some bugs in
the patchset. Sent on list.

Hope this helps.

-- 
MST
