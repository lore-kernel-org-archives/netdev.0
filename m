From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: eepro100 broken on ARM by 2.6.11-rc1 changes
Date: Tue, 15 Feb 2005 23:48:25 +0100
Message-ID: <20050215224825.GB886@xi.wantstofly.org>
References: <20050215211020.GB566@xi.wantstofly.org> <20050215132047.7a33e6ec.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215132047.7a33e6ec.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 15, 2005 at 01:20:47PM -0800, David S. Miller wrote:

> > eepro100 seems to have stopped working between 2.6.10 and 2.6.11-rc2
> > on an embedded ARM platform.  In 2.6.10 I would see this:
> 
> Please check to make sure ARM implements pci_iomap(),
> ioread*()/iowrite*() and friends correctly.

It doesn't.  The generic implementation (lib/iomap.c) assumes that
cookies below 0x10000 are I/O space, and this doesn't hold on the ARM
in general.

In my particular case, the e100 has its I/O space start at 0x100000.

Discussion taken to linux-arm-kernel.


thanks,
Lennert
