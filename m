From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Tue, 17 Nov 2009 19:26:02 +0100
Message-ID: <4B02EABA.3060905@grandegger.com>
References: <1258128892-28800-1-git-send-email-w.sang@pengutronix.de>	<fa686aa40911130939x54ac53f9x173a875a5a4435d3@mail.gmail.com>
	<20091116184416.GA21491@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20091116184416.GA21491-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfram Sang wrote:
> Hi Grant,
> 
> Wolfgang commented on some points already, I will pick up the other remarks,
> just one question:
> 
>>> +       clk_src = of_get_property(np, "fsl,mscan-clk-src", NULL);
>>> +       if (clk_src && strcmp(clk_src, "ip") == 0)
>> Should protect against non-null.  strncmp() maybe?
> 
> "ip" is null-terminated, or what do you mean?

Imagine somebody defines:

  fsl,mscan-clk-src = <0xbaeee>;

Wolfgang.
