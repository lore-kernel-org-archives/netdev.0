From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 4/6] net: use bitrev8
Date: Fri, 20 Oct 2006 11:50:45 +0900
Message-ID: <20061020025045.GB6344@localhost>
References: <20061018164647.GD21820@localhost> <20061019133951.1d463173.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Paul Mackerras <paulus@samba.org>,
	Mirko Lindner <mlindner@syskonnect.de>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:15265 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S2992439AbWJTCtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 22:49:55 -0400
Received: by nf-out-0910.google.com with SMTP id c2so1256900nfe
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 19:49:54 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061019133951.1d463173.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2006 at 01:39:51PM -0700, Andrew Morton wrote:

> A bunch of drivers.
> 
> > ===================================================================
> > --- work-fault-inject.orig/drivers/net/Kconfig
> > +++ work-fault-inject/drivers/net/Kconfig
> > @@ -2500,6 +2500,7 @@ config DEFXX
> >  config SKFP
> >  	tristate "SysKonnect FDDI PCI support"
> >  	depends on FDDI && PCI
> > +	select BITREVERSE
> >  	---help---
> >  	  Say Y here if you have a SysKonnect FDDI PCI adapter.
> >  	  The following adapters are supported by this driver:
> 
> But only one of them selects the library.

Other drivers already select CRC32 and CRC32 selects BITREVERSE.

> But select is problematic and I do wonder whether it'd be simpler to just
> link the thing into vmlinux.

OK. I'll try.

