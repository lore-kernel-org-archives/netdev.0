From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.22 2/4]S2IO: Removing MSI support from the driver
Date: Mon, 02 Jul 2007 08:18:00 -0400
Message-ID: <4688ECF8.9000204@garzik.org>
References: <Pine.GSO.4.10.10706190557030.2608-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Leonid.Grossman@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	Sivakumar.Subramani@neterion.com, sreenivasa.honnur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: Veena Parat <Veena.Parat@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50798 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbXGBMSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:18:05 -0400
In-Reply-To: <Pine.GSO.4.10.10706190557030.2608-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veena Parat wrote:
> 1.Removed MSI support from driver - unused feature
> 2.Removed pci_request_regions call to allocate bar2 as it is not used in driver
> 3.Removed pci_release_regions since pci_request_regions is not done

This is wrong.  pci_request_regions() grabs all the regions for the 
associated PCI device, which is the desired behavior.

Using request_mem_region() is not what you want to do for PCI devices.


