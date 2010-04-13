From: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH] Fix some #includes in CAN drivers
Date: Tue, 13 Apr 2010 11:51:26 +0200
Message-ID: <20100413095125.GB2011@bluebox.local>
References: <20100408192545.GD2004@bluebox.local>
	<20100413.013614.200995710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haas-zsNKPWJ8Piak0Ce0JJ2bFg@public.gmane.org, celston-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, per.dalen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, chripell-LERDrqjqfvZg9hUCZPvPmw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100413.013614.200995710.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Tue, Apr 13, 2010 at 01:36:14AM -0700, David Miller wrote:
> From: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Date: Thu, 8 Apr 2010 21:25:45 +0200
> 
> > In the current implementation, CAN drivers need to #include <linux/can.h>
> > _before_ they #include <linux/can/dev.h>, which is both ugly and
> > unnecessary.
> > 
> > Fix this by including <linux/can.h> in <linux/can/dev.h> and remove the
> > #include <linux/can.h> lines from drivers.
> > 
> > Signed-off-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> 
> This doesn't apply cleanly to net-next-2.6, please respin your patch
> and resubmit.

Ooops, sorry. Will resubmit immediately.

Thanks,
Hans
