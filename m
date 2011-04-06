From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH/RFC] can: mcp251x: Allow pass IRQ flags through
	platform data.
Date: Wed, 06 Apr 2011 12:24:37 -0700 (PDT)
Message-ID: <20110406.122437.183036685.davem@davemloft.net>
References: <1302023321-25182-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1302023321-25182-1-git-send-email-eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
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

From: Enric Balletbo i Serra <eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
Date: Tue,  5 Apr 2011 19:08:41 +0200

> When an interrupt occurs, the INT pin is driven low by the
> MCP251x controller (falling edge) but in some cases the INT
> pin can be connected to the MPU through a transistor or level
> translator which inverts this signal. In this case interrupt
> should be configured in rising edge.
> 
> This patch adds support to pass the IRQ flags via
> mcp251x_platform_data.
> 
> Signed-off-by: Enric Balletbo i Serra <eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>

Applied, thanks.
