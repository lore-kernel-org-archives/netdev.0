From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets V4.
Date: Fri, 21 Sep 2012 16:45:21 -0400
Message-ID: <20120921204521.GA30614@phenom.dumpdata.com>
References: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
 <1347869865.14977.15.camel@zakaz.uk.xensource.com>
 <5B5132A4-93B2-41D0-B1A6-048810565DB5@gridcentric.ca>
 <20120921185258.GA4931@phenom.dumpdata.com>
 <ACFBD23A-6B32-47F3-B71A-37F4557FDE47@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Lagar-Cavilla <andreslc@gridcentric.ca>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	xen-devel <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andres Lagar-Cavilla <andres.lagarcavilla@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ACFBD23A-6B32-47F3-B71A-37F4557FDE47@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > So with this patch when I launch an PVHVM guest on Xen 4.1 I get this
> > in the initial domain and the guest is crashed:
> > 
> > [  261.927218] privcmd_fault: vma=ffff88002a31dce8 7f4edc095000-7f4edc195000, pgoff=c8, uv=00007f4edc15d000
> 
> With this patch? Or with the mmapbatch v2? This is a page fault in a foreign-mapped VMA. Not touched by this grant backend patch we are talking about.
> 
> Does the hypervisor dump anything to its console?
> 
> At which point during xc_hvm_build do you see this? (or elsewhere in the toolstack?)

My apologies. It was Oliver's persistent grant patch that does not like your patch.
