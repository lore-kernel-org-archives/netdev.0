From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] use rtnl_lock_interruptible in 8139 to avoid shutdown hang
Date: Mon, 10 Jan 2005 22:45:22 +0100
Message-ID: <20050110214522.GA17463@lst.de>
References: <20050109121630.GB19599@lst.de> <20050110133714.023aa21b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050110133714.023aa21b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 10, 2005 at 01:37:14PM -0800, David S. Miller wrote:
> On Sun, 9 Jan 2005 13:16:30 +0100
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > The 8139too thread needs to use rtnl_lock_interruptible so it can avoid
> > doing the actual work once it's been kill_proc()ed on module removal
> > time.
> > 
> > Based on debugging and an earlier patch that adds a driver-private
> > semaphore from Herbert Xu.
> 
> I've applied these two patches, they look perfectly fine.
> Thanks Christoph.

Btw, there's some confusing between rtnl_lock and rtnl_shlock (similar
for the other variants).  Is there an agenda behind this versions or
would you take a patch that unifies the lock assecors?
