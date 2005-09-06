From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.13 2/2] 3c59x: add option for using memory-mapped
 PCI I/O resources
Date: Tue, 6 Sep 2005 14:04:14 -0700
Message-ID: <20050906140414.40b65253.akpm@osdl.org>
References: <20050906204147.GC20145@tuxdriver.com>
	<20050906204400.GD20145@tuxdriver.com>
	<20050906205429.GA19319@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750947AbVIFVGN@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050906205429.GA19319@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> wrote:
>
> On Tue, Sep 06, 2005 at 04:44:00PM -0400, John W. Linville wrote:
> > Add module option to enable 3c59x driver to use memory-mapped PCI I/O
> > resources.  This may improve performance for those devices so equipped.
> > 
> > Add "use_mmio=1" to the 3c59x module options in order to enable this
> > functionality.
> 
> I'm not sure a module option makes sense for this setting, except maybe
> as a debugging aid.  You should rather have a flag in the PCI IDs private
> data that can be used to enable mmio for those cards that support it.

I guess it's OK for the initial testing.  Plus we should make the new
feature default to "on" during initial public testing.  I'll make that
change.
