From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Mon, 14 Feb 2011 14:42:00 +0100
Message-ID: <4D593128.8090807@grandegger.com>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>	<20110211150602.GB373@e-circ.dyndns.org>	<C1C4300CE90A406FBDA2388D5491FAD5@subhasishg>	<4D58D854.5090503@grandegger.com>	<1F33D30F9B2D47ECA80CEC807A6C0727@subhasishg>	<4D58F77B.9080005@pengutronix.de>
	<8CB9F2C8F75C4041B9F0691D209DDAFD@subhasishg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8CB9F2C8F75C4041B9F0691D209DDAFD@subhasishg>
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

On 02/14/2011 02:15 PM, Subhasish Ghosh wrote:
> Hello,
> 
> The problem with the "all" implementation is that it hogs the ARM/DSP
> heavily and that's the reason why we specifically avoided this in our
> firmware design.
> Hence, implementing this condition spoils the whole purpose of the PRU!!

Well, I doubt that a CAN controller just supporting 8 CAN identifiers
will make many CAN users happy. Anyway, the CAN identifiers could/should
be configured via SysFS files (as Marc suggested).

Wolfgang.

> --------------------------------------------------
> From: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Sent: Monday, February 14, 2011 3:05 PM
> To: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
> Cc: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>; "Kurt Van Dijck"
> <kurt.van.dijck-/BeEPy95v10@public.gmane.org>;
> <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>;
> <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>; <m-watkins-l0cyMroinI0@public.gmane.org>;
> <nsekhar-l0cyMroinI0@public.gmane.org>; <sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>; "open list:CAN NETWORK
> DRIVERS" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; "open list:CAN NETWORK
> DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; "open list"
> <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
> 
> Hello,
> 
> On 02/14/2011 09:45 AM, Subhasish Ghosh wrote:
>> That is correct, we receive only pre-programmed CAN ids and "all" or
>> "range" implementation is not there in the PRU firmware.
> 
> I'd really like to see that you add a "all" implementation to the
> firmware. Or even better use the standard id/mask approach.
> 
> cheers, Marc
> 
