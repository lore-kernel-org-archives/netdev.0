From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] switch sdla to initcalls
Date: Wed, 21 May 2003 10:19:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521081938.GD22869@wotan.suse.de>
References: <20030521101126.A30197@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20030521101126.A30197@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2003 at 10:11:26AM +0200, Christoph Hellwig wrote:
> Wow, on driver that had it's dirt fingers in both Space.c and setup.c :)

Are you sure this won't change probe order? The normal reason
to keep calls in Space.c is that they're ISA or other non discoverable 
devices and require a specific ISA probe order, otherwise bad things
happen at boot.

The card appears to be non PCI.

-Andi
