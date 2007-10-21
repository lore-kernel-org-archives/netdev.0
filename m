From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 07:13:16 +1000
Message-ID: <1193001196.6745.36.camel@pasglop>
References: <20071020000421.GO29903@austin.ibm.com>
	 <20071019.172706.57467960.davem@davemloft.net>
	 <20071020004610.GR29903@austin.ibm.com>
	 <20071019.175308.54212640.davem@davemloft.net>
	 <1192862606.7688.4.camel@concordia>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mcarlson@broadcom.com, linuxppc-dev@ozlabs.org, mchan@broadcom.com,
	linux-pci@atrey.karlin.mff.cuni.cz
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52507 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbXJUVNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 17:13:41 -0400
In-Reply-To: <1192862606.7688.4.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> That's a pity, but AFAIK it shouldn't be a problem because we don't
> enable CONFIG_PM on those machines anyway. If we ever want to we'll need
> to sort out with firmware how that will work WRT restoring MSI state.

I think the current generic code for pci_restore_msi_state() or whatever
it's called wilol directly call into write_msi_msg() etc... might be a
problem.

Ben.


