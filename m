From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] use rtnl_lock_interruptible in 8139 to avoid
 shutdown hang
Date: Mon, 10 Jan 2005 17:50:42 -0800
Message-ID: <20050110175042.53eaa3c1.davem@davemloft.net>
References: <20050109121630.GB19599@lst.de>
	<20050110133714.023aa21b.davem@davemloft.net>
	<20050110214522.GA17463@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20050110214522.GA17463@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Jan 2005 22:45:22 +0100
Christoph Hellwig <hch@lst.de> wrote:

> Btw, there's some confusing between rtnl_lock and rtnl_shlock (similar
> for the other variants).  Is there an agenda behind this versions or
> would you take a patch that unifies the lock assecors?

What exactly do you plan to change?
