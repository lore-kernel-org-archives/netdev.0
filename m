From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Wed, 01 Aug 2007 18:50:49 -0400
Message-ID: <46B10E49.1080904@garzik.org>
References: <1185957077.5552.22.camel@dell> <200708020006.13457.mb@bu3sch.de> <adaodhq6gal.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Michael Chan <mchan@broadcom.com>,
	davem@davemloft.net, netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55679 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269AbXHAWuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 18:50:54 -0400
In-Reply-To: <adaodhq6gal.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > > +	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5710,
>  > > +		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5710 },
> 
> FWIW, this could be neater as
> 
> 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5710), BCM5710 }

Yes.  And additionally, I prefer (but not require) that people directly 
use a hexidecimal constant in the PCI ID table for device ID, if that is 
the only place in the entire codebase referring to that PCI device ID.

Using a named constant for a single-use PCI device ID merely aggrevates 
include/linux/pci_ids.h patching headache for what is ultimately an 
arbitrary number [usually] picked out of thin air by the hw vendor.

	Jeff



