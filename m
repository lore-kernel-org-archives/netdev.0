From: Christoph Hellwig <hch@infradead.org>
Subject: Re: struct pci_device_id declaration cleanups
Date: Thu, 6 Mar 2008 07:25:18 -0500
Message-ID: <20080306122518.GB28561@infradead.org>
References: <1204800947-21569-1-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34422 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbYCFMZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 07:25:19 -0500
Content-Disposition: inline
In-Reply-To: <1204800947-21569-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 11:55:38AM +0100, Jonas Bonn wrote:
> 
> This set of patches applies the macro DECLARE_PCI_DEVICE_TABLE to the 
> declarations of struct pci_device_id in several network drivers.  The drivers
> build cleanly with these patches (without any new warnings) on both x86 and 
> PowerPC.

Why would we want this macro?  It looks slightly ugly at least..

