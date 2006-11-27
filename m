From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] NetXen: 64-bit memory fixes, driver cleanup
Date: Mon, 27 Nov 2006 10:23:26 -0800
Message-ID: <20061127102326.563f4e52@dxpl.pdx.osdl.net>
References: <200611171536.kAHFa3os005563@dut39.unminc.com>
	<20061117084049.555e14d0@localhost.localdomain>
	<1163845689.4822.6.camel@nbsanjeev>
	<20061120104553.434b6ec5@freekitty>
	<1164299572.4505.9.camel@nbsanjeev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@netxen.com>,
	netdev <netdev@vger.kernel.org>,
	brazilnut <brazilnut@us.ibm.com>, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com,
	wendyx <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:41606 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1758514AbWK0SXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 13:23:43 -0500
To: sanjeev@netxen.com
In-Reply-To: <1164299572.4505.9.camel@nbsanjeev>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Nov 2006 08:32:52 -0800
Sanjeev Jorapur <sanjeev@netxen.com> wrote:

> > 
> > You should then set the same value for pci_set_dma_mask, because then the IOMMU
> > can help. See both b44 or tg3 drivers, they have to deal with odd size masks.
> > I don't think you have to do all the bounce buffer work in the driver.
> > 
> 
> We had tried something like this earlier, but found that on some
> platforms (Opteron, IA64), we got kernel panics when the kernel
> ran out of translation entries.

That's a bug, it should be fixed there.  It would make sense to reduce the size
of the Tx queue if not enough translation entries were available.
