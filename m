From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v2 1/3] can: at91_can: clean up usage of
	AT91_MB_RX_FIRST and AT91_MB_RX_NUM
Date: Sat, 22 Jan 2011 08:50:17 +0100
Message-ID: <20110122075016.GA542@e-circ.dyndns.org>
References: <1294752085-30151-1-git-send-email-mkl@pengutronix.de>
	<1294752085-30151-2-git-send-email-mkl@pengutronix.de>
	<4D349D8C.3010403@pengutronix.de>
	<20110121.165409.200115988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110121.165409.200115988.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Fri, Jan 21, 2011 at 04:54:09PM -0800, David Miller wrote:
> > On 01/11/2011 02:21 PM, Marc Kleine-Budde wrote:
> >> This patch cleans up the usage of two macros which specify the mailbox
> >> usage. AT91_MB_RX_FIRST and AT91_MB_RX_NUM define the first and the
> >> number of RX mailboxes. The current driver uses these variables in an
> >> unclean way; assuming that AT91_MB_RX_FIRST is 0;
> >> 
> >> This patch cleans up the usage of these macros, no longer assuming
> >> AT91_MB_RX_FIRST == 0.
> >> 
> >> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > 
> > Any comments on this?
> 
> I would also seriously like to see these changes get some feedback,
> they've been rotting in patchwork for more than a week.

I have no experience with this specific chip.
IMO, this chip errata (as explained in the post) got an elegant solution.
That part definitely gets my
Acked-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>

Regards,
Kurt
