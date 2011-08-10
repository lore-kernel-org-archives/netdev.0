From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v10 4/5] [powerpc] Add flexcan device support for p1010rdb.
Date: Wed, 10 Aug 2011 05:15:36 -0500
Message-ID: <20110810101535.GO4926@sgi.com>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<1312945564-6626-5-git-send-email-holt@sgi.com>
	<4E4255B1.6050001@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E4255B1.6050001-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2011 at 11:56:01AM +0200, Marc Kleine-Budde wrote:
> On 08/10/2011 05:06 AM, Robin Holt wrote:
> > diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platforms/85xx/clock.c
> > new file mode 100644
> > index 0000000..16fae04
> > --- /dev/null
> > +++ b/arch/powerpc/platforms/85xx/clock.c
> > @@ -0,0 +1,53 @@
...
> > +void __init mpc85xx_clk_init(void)
> > +{
> > +	clk_functions = mpc85xx_clk_functions;
> > +}
> > +
> 
> git is even picker then me: "new blank line at EOF."
> please fix

That reminded me that I have slacked on using checkpatch.pl in a few
resends and it really does not like this patch at all so I will rework
the patch with its concerns.  I am going to hold off on resending until
there are more substantial changes.

Thanks,
Robin
