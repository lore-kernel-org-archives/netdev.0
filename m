From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 08/11] ixgbe: walk pci-e bus to find minimum width
Date: Mon, 15 Apr 2013 20:48:08 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5855B20959@ORSMSX106.amr.corp.intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1365765866-15741-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJZOPZ+eBzbfSo1evWNsQWFwu7_qiZsai3Xgf7MvXjbeKSssAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62060 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614Ab3DOUsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 16:48:13 -0400
In-Reply-To: <CAJZOPZ+eBzbfSo1evWNsQWFwu7_qiZsai3Xgf7MvXjbeKSssAA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> Sent: Saturday, April 13, 2013 2:28 PM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Keller, Jacob E; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 08/11] ixgbe: walk pci-e bus to find minimum
> width
> 
> On Fri, Apr 12, 2013 at 2:24 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Jacob Keller <jacob.e.keller@intel.com>
> >
> > This patch adds a function which enables the ixgbe driver to walk up
> the PCI bus
> > for the device and query the PCI config space for the bus width at each
> > point. This enables the driver to determine what the minimum PCIe
> width is for
> > the device, and warn the user if it is not enough.
> 
> If possible without too much pain, I think we may want to add this
> somehow as generic function which would allow other drivers to enjoy
> from this logic too, agree?
> 
> Or.

I will look into re-writing this as a generic function.

Thanks!

- Jake
