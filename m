From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 06/17] sky2: advanced error reporting
Date: Wed, 9 May 2007 12:05:51 -0500
Message-ID: <20070509170551.GW4452@austin.ibm.com>
References: <20070509034949.624934448@linux-foundation.org> <20070509035028.970057572@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37733 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbXEIRFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 13:05:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l49H5rKM014144
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 13:05:53 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l49H5qsf198256
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 11:05:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l49H5p5O009754
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 11:05:52 -0600
Content-Disposition: inline
In-Reply-To: <20070509035028.970057572@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 08:49:55PM -0700, Stephen Hemminger wrote:
> Use the kernel interfaces for advanced error reporting.
> This should be cleaner and clear up errors on boot.

Hmm. I thought that the AER functions would eventually 
be handled by the struct pci_error_handlers callbacks,
so that dev drivers wouldn't actually have code such as

> +		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &status);
> +		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &mask);

in them. But perhaps I haven't studed what this drivr is trying to 
do; nor have I really kept track of the aer code.

--linas

