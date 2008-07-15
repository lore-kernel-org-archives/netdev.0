From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 19:14:57 -0400
Message-ID: <20080715231457.GA15266@redhat.com>
References: <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org> <20080715223626.GA10532@redhat.com> <487D2AEE.8030309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365AbYGOXW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 19:22:26 -0400
Content-Disposition: inline
In-Reply-To: <487D2AEE.8030309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2008 at 06:55:42PM -0400, Jeff Garzik wrote:

 > >  > * [optional] would prefer CONFIG_8139TOO_PIO be handled at compile time, 
 > >  > by changing the initialized value
 > > 
 > > This bit should be taken care of in rtl8139_init_module() at the bottom..
 > > 
 > > +       /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
 > > +#ifdef CONFIG_8139TOO_PIO
 > > +       use_io = 1;
 > > +#endif
 > 
 > Right, I was saying I prefer simply to set the initialized value 
 > appropriately, and avoid the extra code dollup during module load.

Oh, you mean something like..

static int use_io = CONFIG_8139TOO_PIO;

?

	Dave

-- 
http://www.codemonkey.org.uk
