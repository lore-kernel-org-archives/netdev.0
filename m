From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets V4.
Date: Fri, 21 Sep 2012 09:28:36 -0400
Message-ID: <20120921132836.GA13090@phenom.dumpdata.com>
References: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
 <1347869865.14977.15.camel@zakaz.uk.xensource.com>
 <5B5132A4-93B2-41D0-B1A6-048810565DB5@gridcentric.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	xen-devel <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5B5132A4-93B2-41D0-B1A6-048810565DB5@gridcentric.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>
> > 
> > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > 
> > Since this is more about grant tables than netback this should probably
> > go via Konrad rather than Dave, is that OK with you Dave?
> 
> If that is the case hopefully Konrad can deal with the two typos? Otherwise happy to re-spin the patch.
> Thanks!

David, I pulled it in my tree since the only changes it does to drivers/net/xen-* is
change the name of the function to call in the bowels of grant API.

HYPERVISOR_grant_table_op(GNTTABOP_copy, netbk->tx_copy_ops, nr_gops);
to
gnttab_batch_copy(netbk->tx_copy_ops, nr_gops);

Hope that is OK - if not I can prep a branch that has patches that this depends
on that you can pull.
