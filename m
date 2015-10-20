From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next 11/17] i40e: Add promiscuous on VLAN support
Date: Tue, 20 Oct 2015 15:31:42 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0789429C4D@ORSMSX108.amr.corp.intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1444715598-20970-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20151013.041408.880270217805854932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Singhai, Anjali" <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49108 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbbJTPbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:31:47 -0400
In-Reply-To: <20151013.041408.880270217805854932.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, October 13, 2015 4:14 AM
> To: Kirsher, Jeffrey T
> Cc: Rose, Gregory V; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 11/17] i40e: Add promiscuous on VLAN support
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 12 Oct 2015 22:53:12 -0700
> 
> > From: Greg Rose <gregory.v.rose@intel.com>
> >
> > NFV use cases require the ability to steer packets to VSIs by VLAN tag
> > alone while being in promiscuous mode for multicast and unicast MAC
> > addresses.  These two new functions support that ability.
> >
> > Change-ID: Ifef704b07e0ee8a39d3c351dbd5dc83bb2f63c45
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Nothing in the driver calls these functions.
> 
> Please do not add code or defines or facilities that are completely unused
> in the upstream driver.

The patch(es) that use these functions are not yet prepared.  We will wait until they're ready to submit these patches.  Sorry for the confusion but I was out on vacation and didn't have a chance to coordinate this with Jeff.

Jeff,

We needed the VF trust code in the kernel before we could add in these additional patches.  We can work with Anjali to get those now that the VF trust feature is in the kernel.

- Greg
