From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2.6.13 2/2] 3c59x: add option for using memory-mapped PCI I/O resources
Date: Tue, 6 Sep 2005 21:54:29 +0100
Message-ID: <20050906205429.GA19319@infradead.org>
References: <20050906204147.GC20145@tuxdriver.com> <20050906204400.GD20145@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750908AbVIFUyb@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050906204400.GD20145@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 06, 2005 at 04:44:00PM -0400, John W. Linville wrote:
> Add module option to enable 3c59x driver to use memory-mapped PCI I/O
> resources.  This may improve performance for those devices so equipped.
> 
> Add "use_mmio=1" to the 3c59x module options in order to enable this
> functionality.

I'm not sure a module option makes sense for this setting, except maybe
as a debugging aid.  You should rather have a flag in the PCI IDs private
data that can be used to enable mmio for those cards that support it.
