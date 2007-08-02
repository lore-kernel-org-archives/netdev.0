From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Thu, 02 Aug 2007 21:13:45 +0300
Message-ID: <46B21ED9.1060500@broadcom.com>
References: <1185957077.5552.22.camel@dell>
 <200708020006.13457.mb@bu3sch.de> <adaodhq6gal.fsf@cisco.com>
 <46B10E49.1080904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>,
	"Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, lusinsky@broadcom.com, eilong@broadcom.com
To: "Jeff Garzik" <jeff@garzik.org>,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3439 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087AbXHBSOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 14:14:04 -0400
In-Reply-To: <46B10E49.1080904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff, Roland,

Thanks for taking a look.

Jeff Garzik wrote:
> Roland Dreier wrote:
>>  > > +    { PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5710,
>>  > > +        PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5710 },
>>
>> FWIW, this could be neater as
>>
>>     { PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_5710), BCM5710 }

OK

> Yes.  And additionally, I prefer (but not require) that people directly 
> use a hexidecimal constant in the PCI ID table for device ID, if that is 
> the only place in the entire codebase referring to that PCI device ID.
> 
> Using a named constant for a single-use PCI device ID merely aggrevates 
> include/linux/pci_ids.h patching headache for what is ultimately an 
> arbitrary number [usually] picked out of thin air by the hw vendor.
> 
>     Jeff

For now it is the only place used, but this will change very soon, once 
we have several flavors of the chip out. then we will have to handle 
each in a slightly different manner.

Eliezer



