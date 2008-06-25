From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 16:39:31 -0400
Message-ID: <20080625203931.GA32408@gospo.rdu.redhat.com>
References: <20080625141511.GH22981@gospo.rdu.redhat.com> <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com> <20080625203519.GU4392@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080625203519.GU4392@parisc-linux.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2008 at 02:35:19PM -0600, Matthew Wilcox wrote:
> On Wed, Jun 25, 2008 at 01:29:19PM -0700, Brandeburg, Jesse wrote:
> > > -	igb_irq_disable(adapter);
> > > +	disable_irq(adapter->pdev->irq);
> > 
> > how does changing to disable_irq/enable_irq work with MSI and MSI-X
> > interrupts?
> 
> Works just fine.  There's a disable_irq method in the irq_chip that
> knows how to disable a particular type of interrupt.
> 

Sure does.  Just for the record, most of the other net-drivers do it
this way too.
