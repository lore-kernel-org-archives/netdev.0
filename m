From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] switch sdla to initcalls
Date: Wed, 21 May 2003 10:26:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521082630.GF22869@wotan.suse.de>
References: <20030521101126.A30197@lst.de> <20030521081938.GD22869@wotan.suse.de> <20030521102512.A30373@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20030521102512.A30373@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2003 at 10:25:12AM +0200, Christoph Hellwig wrote:
> On Wed, May 21, 2003 at 10:19:39AM +0200, Andi Kleen wrote:
> > On Wed, May 21, 2003 at 10:11:26AM +0200, Christoph Hellwig wrote:
> > > Wow, on driver that had it's dirt fingers in both Space.c and setup.c :)
> > 
> > Are you sure this won't change probe order? The normal reason
> > to keep calls in Space.c is that they're ISA or other non discoverable 
> > devices and require a specific ISA probe order, otherwise bad things
> > happen at boot.
> > 
> > The card appears to be non PCI.
> 
> Yes, it's a ISA device.  But it has the sdla%d namespace for it's own
> and support only a single card anyway.  There's not much chance of
> changing any probe order here.

ISA probe order has nothing to do with namespaces or single cards. It 
works by reading values from specific registers and completely different
devices can conflict.

-Andi
> 
