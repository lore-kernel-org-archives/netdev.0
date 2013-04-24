From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/14] pci: Add SRIOV helper function to determine
 if VFs are assigned to guest
Date: Wed, 24 Apr 2013 16:18:25 -0400 (EDT)
Message-ID: <20130424.161825.1007847105309092978.davem@davemloft.net>
References: <5175B0A9.7070100@intel.com>
	<20130423125101.00005bb7@unknown>
	<CAErSpo58vRW+QoHMTzo4vNi4n8Z2RhG43rBesTUJS-4HRwfd1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756997Ab3DXUS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 16:18:29 -0400
In-Reply-To: <CAErSpo58vRW+QoHMTzo4vNi4n8Z2RhG43rBesTUJS-4HRwfd1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 24 Apr 2013 14:10:38 -0600

> But this is no worse in either respect than the code it replaces, and
> it's certainly better to have it all in one place, so:
> 
> Acked-by: Bjorn Helgaas <bhelgaas@google.com>
> 
> If you have a chance, you could remove the "extern" from the
> declaration in include/linux/pci.h.  There's a mix there right now,
> and I have a patch in the queue that removes them all.

Jeff please respin your pull request with Bjorn's ACK as well as
the "extern" removal he's asking for.

Thanks.
