From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Tue, 22 Apr 2008 10:08:44 -0500
Message-ID: <20080422150844.GA15474@ld0162-tx32.am.freescale.net>
References: <200804161640.42693.laurentp@cse-semaphore.com>
	<200804181334.34229.laurentp@cse-semaphore.com>
	<20080421175627.GD4134@ld0162-tx32.am.freescale.net>
	<200804221055.09038.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200804221055.09038.laurentp@cse-semaphore.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2008 at 10:55:06AM +0200, Laurent Pinchart wrote:
> On Monday 21 April 2008 19:56, Scott Wood wrote:
> > The memory-constrained platform I had in mind was 8xx, which doesn't use
> > bitbanged MDIO.  It might nice to keep the gpiolib bit separate to avoid
> > situations such as ep8248e where mdiobb would be the only thing requiring
> > a gpiolib binding, though -- but it shouldn't be two separate bitbang
> > drivers, just the existing bitbang driver plus some glue code that binds
> > it to gpiolib.
> 
> I would be fine with that if the glue code wasn't 90% of the whole driver. 
> There is really little (not to say nothing) that can be shared between the 
> two drivers.

I think we're thinking of a different pair of drivers...  I thought you
were talking about duplicating drivers/net/phy/mdio-bitbang.c, not
drivers/net/fs_enet/mii-bitbang.c.

-Scott
