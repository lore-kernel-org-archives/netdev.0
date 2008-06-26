From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 22:40:40 -0400
Message-ID: <20080626024040.GB32408@gospo.rdu.redhat.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com> <20080625203519.GU4392@parisc-linux.org> <20080625203931.GA32408@gospo.rdu.redhat.com> <20080625.172911.189232903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matthew@wil.cx, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080625.172911.189232903.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2008 at 05:29:11PM -0700, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 25 Jun 2008 16:39:31 -0400
> 
> > Just for the record, most of the other net-drivers do it
> > this way too.
> 
> Ummm, really?
> 
> No NAPI based driver I ever wrote does this.

For the poll_controller routines (which is what this patch is about),
quite a few do (bnx2, bnx2x, b44, e1000, and e1000e to name a few).

Much like the other drivers for Intel hardware, the function with
'netpoll' in the name is used for the poll_controller routine whereas
the napi poll routines all have 'clean' in the name.

Sorry if 'most' was misleading, but there are quite a few drivers that
do.
