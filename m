From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/5] NetXen: temp monitoring, newer firmware support, mm
 footprint reduction
Date: Thu, 30 Nov 2006 19:13:11 -0800
Message-ID: <20061130191311.4d9ba296@localhost.localdomain>
References: <20061130185002.GA32305@us.ibm.com>
	<20061201000204.GA19837@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:18663 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1758380AbWLADN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 22:13:56 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061201000204.GA19837@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > @@ -869,7 +937,10 @@ static inline void netxen_nic_disable_in
> >  	/*
> >  	 * ISR_INT_MASK: Can be read from window 0 or 1.
> >  	 */
> > -	writel(0x7ff, (void __iomem *)(adapter->ahw.pci_base + ISR_INT_MASK));
> > +	writel(0x7ff,
> > +	       (void __iomem
> > +		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
> > +
> 
> Yuck

If pci_base were correctly typed __iomem the casting would not
be needed.

