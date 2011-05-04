From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 4 May 2011 15:11:53 +0200
Message-ID: <201105041511.54095.arnd@arndb.de>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<201104271525.28512.arnd@arndb.de>
	<15AD189F851849F69A011B6F4D1DDB6C@subhasishg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Subhasish Ghosh" <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <15AD189F851849F69A011B6F4D1DDB6C@subhasishg>
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

On Wednesday 04 May 2011, Subhasish Ghosh wrote:
> CAN requires mail box IDs to be programmed in. But, the socket
> CAN subsystem supports only software filtering of the mail box IDs.
> 
> So, the mail box IDs programmed into socket CAN during initialization
> does not propagate into the hardware. This is planned to be a future
> implementation in Socket CAN.
> 
> In our case, we support hardware filtering, to work around with this,
> Wolfgang (Socket CAN owner) suggested that we implement
> this using sysfs.
> 
> These setting are not for debugging, but to program the mail box IDs
> into the hardware. 

Ok, I see. Can you point me to that discussion?

Wolfgang, I'm a bit worried by the API being split between sockets and sysfs.
The problem is that once the sysfs API is established, users will start
relying on it, and you can no longer migrate away from it, even when
a later version of the Socket CAN also supports setting through a different
interface. What is the current interface to set mail box IDs in software?
How hard would it be to implement that feature in Socket CAN?

Is that something that Subhasish or someone else could to as a prerequisite
to merging the driver?

	Arnd
