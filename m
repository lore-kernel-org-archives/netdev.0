From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] switch iph5526_probe to initcalls
Date: Sun, 15 Jun 2003 20:05:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615180514.GA5006@lst.de>
References: <20030615180011.GA4922@lst.de> <20030615.105811.55734399.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030615.105811.55734399.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 15, 2003 at 10:58:11AM -0700, David S. Miller wrote:
>    From: Christoph Hellwig <hch@lst.de>
>    Date: Sun, 15 Jun 2003 20:00:11 +0200
> 
>    It's a pci driver so it has no business in Space.c
>    
>    p.s. it doesn't compile with or without the patch due to scsi issues..
>    
> Can we put this patch on hold until that's resolved?

Well, we could.  It's just that I doubt anyone will fix it anytime soon,
the hardware doesn't seem to be widely used and it's hard to touch the
driver without a barfbag nearby.  (and you also applied the alloc_fcdev
changes for it :))
