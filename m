From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: The new SSB subsystem for bcm43xx (and others)
Date: Sat, 10 Feb 2007 20:46:30 +0000
Message-ID: <20070210204630.GA27274@srcf.ucam.org>
References: <200612221359.25093.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Felix Fietkau <nbd@nbd.name>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:35712 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbXBJUqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 15:46:43 -0500
Content-Disposition: inline
In-Reply-To: <200612221359.25093.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm testing with your bcm43xx git tree, which I'm guessing is the 
current ssb code. The only problem I've found is that there doesn't seem 
to be any sysfs relationship between the ssb bus and (in this case) the 
PCI device that it's associated with. Is this fixable? Right now it 
appears as an entirely separate branch of the device tree, which doesn't 
seem quite right.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
