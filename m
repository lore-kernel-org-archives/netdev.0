From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: can: hardware vs. software filter
Date: Wed, 11 May 2011 22:03:10 -0500
Message-ID: <20110512030245.GA253@e-circ.dyndns.org>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
	<201105112331.47954.arnd@arndb.de>
	<201105112344.44171.arnd@arndb.de> <4DCB103B.30801@pengutronix.de>
	<20110511235652.7ccddb3b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110511235652.7ccddb3b-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
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

On Wed, May 11, 2011 at 11:56:52PM +0100, Alan Cox wrote:
> > I'm not sure if reprogramming hardware filters on the fly works on evey
> > can core. The more conservative solution would be to configure the
> > filter list globally (+when the interface is down) via netlink.
> 
> For anything that isn't so braindead it ought to be done on the fly and
> behind the users back to avoid having to make app code specially aware.

> If the lists are fixed either in firmware or in software the stack needs
> to error attempts to use anything else

That is the best guarantee to let users never use this.
A tool like 'candump' should not know about any pre-configured
filter that is in place. It's the responsibility of the root user
to put proper preconfigured filters.

A lot of code would be spent to allow an application to request
software filters that fit in the preconfigured ones.
IMHO its the root users job to judge about a proper preconfigured
filter that suits the applications that run. The applications should
then be able to request any software filter they like, the root user
decided on limiting traffic.

This poses a problem in that an application may depend on these filters
for its proper operation. That exactly is the responsibility of the
root user who restricts the preconfigured filter.

Kurt
