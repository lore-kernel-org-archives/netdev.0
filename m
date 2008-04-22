From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Tue, 22 Apr 2008 11:04:22 -0500
Message-ID: <20080422160422.GA16177@ld0162-tx32.am.freescale.net>
References: <200804161640.42693.laurentp@cse-semaphore.com>
	<200804221721.51461.laurentp@cse-semaphore.com>
	<20080422153652.GF15474@ld0162-tx32.am.freescale.net>
	<200804221755.16419.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200804221755.16419.laurentp@cse-semaphore.com>
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

On Tue, Apr 22, 2008 at 05:55:13PM +0200, Laurent Pinchart wrote:
> On Tuesday 22 April 2008 17:36, Scott Wood wrote:
> > The only reason I can see for that would be if the gpiolib version
> > doesn't work on arch/ppc -- but that's not going to be a problem for very
> > much longer.
> 
> Didn't you mention platforms such as ep8248e as well, where mdiobb would be 
> the only gpiolib user ?

That was when I thought you were talking about changing
drivers/net/phy/mdio-bitbang.c.  ep8248e doesn't use
drivers/net/fs-enet/mii-bitbang.c.

> > It'd be nice to be able to give phylib an OF node rather than a string,
> > though...
> 
> Doesn't phylib have non-OF users ?

I meant as an option, not the only way to specify it.

-Scott
