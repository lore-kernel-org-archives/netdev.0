From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] clean up of netif_rx_reschedule() changes in drivers
Date: Mon, 29 Dec 2008 10:37:57 -0500
Message-ID: <20081229153757.GA2857@localhost.localdomain>
References: <20081229110041.0eca977a.sfr@canb.auug.org.au> <20081229102509.GA11111@linux.vnet.ibm.com> <20081229214144.43be8c1d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>, netdev@vger.kernel.org,
	ppc-dev <linuxppc-dev@ozlabs.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081229214144.43be8c1d.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 29, 2008 at 09:41:44PM +1100, Stephen Rothwell wrote:
> Hi Kamalesh,
> 
> On Mon, 29 Dec 2008 15:55:29 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> >
> > I hit similar build failure due to the change in the netif_rx_reschedule()
> > 
> > drivers/net/ehea/ehea_main.c: In function 'ehea_poll':
> > drivers/net/ehea/ehea_main.c:844: warning: passing argument 1 of 'netif_rx_reschedule' from incompatible pointer type
> > drivers/net/ehea/ehea_main.c:844: error: too many arguments to function 'netif_rx_reschedule'
> > make[3]: *** [drivers/net/ehea/ehea_main.o] Error 1
> 
> Linus already took a patch for ibmveth and ehea.
> 
> > greping through the sources for the changes missed out, we have
> > 
> 	.
> 	.
> > 
> > Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> > --
> >  drivers/net/arm/ep93xx_eth.c |    2 +-
> >  drivers/net/arm/ixp4xx_eth.c |    2 +-
> >  drivers/net/wan/ixp4xx_hss.c |    2 +-
> >  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> Thanks for the patch, I assume that Dave or Linus will take care of that.
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/

Thanks guys, not sure how my patch missed that.  I did an allmodconfig build
that passed successfully.  Thanks!

Acked-by: Neil Horman <nhorman@tuxdriver.com>
