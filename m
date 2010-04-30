From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
 according to hardware errata
Date: Fri, 30 Apr 2010 12:27:02 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90622DE3C2@orsmsx509.amr.corp.intel.com>
References: <20100427133232.25490.92973.stgit@localhost.localdomain>
	<20100429074606.GA12437@kryten>
	<8DD2590731AB5D4C9DBF71A877482A9062274501@orsmsx509.amr.corp.intel.com>
 <20100429.120416.184828647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "anton@samba.org" <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"mjg@redhat.com" <mjg@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:32894 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934254Ab0D3T1G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 15:27:06 -0400
In-Reply-To: <20100429.120416.184828647.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, April 29, 2010 12:04 PM, David Miller wrote:
> From: "Allan, Bruce W" <bruce.w.allan@intel.com>
> Date: Thu, 29 Apr 2010 10:19:56 -0700
> 
>> Your patch is probably the correct thing to do but I'm not all that
>> familiar with the ppc64 architecture.  Would you please provide the
>> output of 'lspci -t' and 'lspci -vvv -xxx'.
> 
> You're not guarenteed for there to be a pci_dev backing the top-level
> host controller, at the very least.  Some platforms don't even
> implement the PCI config space for the host controller, whilst on
> others access to them is protected by the hypervisor.
> 
> So you can't go poking around the PCI host controller registers
> unconditionally.
> 
> The same OOPS probably would happen on Sparc64 in some configurations
> too.  Although all of my PCI-E slots do have PCI-E express switch port
> nodes, so maybe it wouldn't trigger here.

In that case, I agree with Anton's patch.

Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>

Thanks,
Bruce.