From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: Intel and TOE in the news
Date: Sun, 20 Feb 2005 08:46:07 -0800
Message-ID: <20050220164607.GA27891@gate.ebshome.net>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org> <20050219114624.373af63f.davem@davemloft.net> <m1psywb8i4.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <m1psywb8i4.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 09:27:31PM +0100, Andi Kleen wrote:
> <speculating freely>
> 
> It would be nice if the NIC could asynchronously trigger prefetches in
> the CPU. Currently a lot of the packet processing cost goes
> to waiting for read cache misses.

Just FYI :), Freescale 85xx TSECs can prefetch buffers into L2 cache. 
IIRC they call it buffer "stashing" and gianfar driver has a config 
option to enable such behavior.

But in embedded world you usually don't see flashy PR releases for 
such features :).

--
Eugene.
