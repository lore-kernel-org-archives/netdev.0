From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/11] can: at91_can: add support for AT91SAM9X5 series
Date: Tue, 07 Jun 2011 01:05:05 -0700 (PDT)
Message-ID: <20110607.010505.1354196431467417506.davem@davemloft.net>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1307367780-30715-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date: Mon,  6 Jun 2011 15:42:49 +0200

> Hello,
> 
> this patch series add support for the at91_can core on the upcoming
> at91sam9x5 SOC series.
> 
> The original at91_can driver supports the at91sam9263 which has 16
> mailboxes, but the CAN core on the at91sam9x5 has only 8. Most constants
> used in the RX and TX path are derived from the number of mailboxes.
> 
> This patch series changes the driver from a static, compile time setup
> of the mailboxes to a dynamic one. Patches 1-4 clean up the driver, 5+6
> simplify the usage of the constants, patch 7 converts all derived constants
> into functions. Patch 8 will add id_table support to the driver then all
> remaining constants are converted into functions using the run time
> selected mailbox constants. The next patch (9) takes care about an
> at91sam9263 specific errata fix. Patch 10 and 11 will finally add supoprt
> for the at91sam9x5 SOC.
> 
> This patch series applies to current net-next-2.6/master and has been tested
> on a sam9263 and sam9x5ek.
> (Allthough, the sam9x5 support is not mainline yet).
> 
> please review and consider to apply,
> Marc
> 
> The following changes since commit e3cc055c18ab575291acf0af7622a2e97c4728fa:
> 
>   include/net: Remove unnecessary semicolons (2011-06-05 14:33:40 -0700)
> 
> are available in the git repository at:
>   git://git.pengutronix.de/git/mkl/linux-2.6.git can/at91-sam9x5

Pulled, t hanks Marc.
