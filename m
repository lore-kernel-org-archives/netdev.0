From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] [e1000] Lower the MSI unavailable message to INFO priority
Date: Thu, 17 May 2007 15:13:24 -0700
Message-ID: <464CD384.5030202@intel.com>
References: <200705152359.l4FNxPcS018779@tazenda.hos.anvin.org> <464A512C.9080104@garzik.org> <464B229B.7060702@intel.com> <464CC5EC.4020202@redhat.com> <464CC92B.9080800@intel.com> <464CCD17.4000908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	e1000-devel@lists.sourceforge.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62129 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755413AbXEQWN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 18:13:27 -0400
In-Reply-To: <464CCD17.4000908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> for now. If MSI is breaking with a 10gig adapter I think people 
>> appreciate the error.
> 
> 
> No, that is same invalid reasoning discussed earlier in this thread. 
> ixgb needs patching for this problem too.

OK then... A patch that does the exact same for ixgb as I did for e1000 is 
underway (remove #ifdef CONFIG_PCI_MSI, fix pci_disable_msi leak...).

Cheers,

Auke
