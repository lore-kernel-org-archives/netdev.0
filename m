From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] use rtnl_lock_interruptible in 8139 to avoid
 shutdown hang
Date: Mon, 10 Jan 2005 13:37:14 -0800
Message-ID: <20050110133714.023aa21b.davem@davemloft.net>
References: <20050109121630.GB19599@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20050109121630.GB19599@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 9 Jan 2005 13:16:30 +0100
Christoph Hellwig <hch@lst.de> wrote:

> The 8139too thread needs to use rtnl_lock_interruptible so it can avoid
> doing the actual work once it's been kill_proc()ed on module removal
> time.
> 
> Based on debugging and an earlier patch that adds a driver-private
> semaphore from Herbert Xu.

I've applied these two patches, they look perfectly fine.
Thanks Christoph.
