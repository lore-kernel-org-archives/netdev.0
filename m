From: Matt Porter <mporter@kernel.crashing.org>
Subject: Re: [PATCH] emac: filter illegal frame sizes
Date: Wed, 2 Mar 2005 09:29:18 -0700
Message-ID: <20050302092918.A30946@cox.net>
References: <20050218101245.D11439@cox.net> <4216FD64.9020509@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4216FD64.9020509@pobox.com>; from jgarzik@pobox.com on Sat, Feb 19, 2005 at 03:48:36AM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 03:48:36AM -0500, Jeff Garzik wrote:
> Matt Porter wrote:
> > Fix to drop frames that are too large for the current MTU.
> 
> What is this fixing?
> 
> You should be passing all frames up to the software stack.

I was originally fixing the issue where the driver was only allocating
rx buffers big enough for the configured MTU and got a bit
overzealous. I pulled out the filtering hunks so we always allocate
skbs large enough to handle a full size jumbo frame and pass everything
up to the stack...new patch to follow.

-Matt
