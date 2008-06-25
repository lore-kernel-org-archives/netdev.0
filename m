From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 14:35:19 -0600
Message-ID: <20080625203519.GU4392@parisc-linux.org>
References: <20080625141511.GH22981@gospo.rdu.redhat.com> <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2008 at 01:29:19PM -0700, Brandeburg, Jesse wrote:
> > -	igb_irq_disable(adapter);
> > +	disable_irq(adapter->pdev->irq);
> 
> how does changing to disable_irq/enable_irq work with MSI and MSI-X
> interrupts?

Works just fine.  There's a disable_irq method in the irq_chip that
knows how to disable a particular type of interrupt.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
