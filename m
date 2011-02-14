From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for
	Bosch C_CAN controller
Date: Sun, 13 Feb 2011 21:43:03 -0800 (PST)
Message-ID: <20110213.214303.63037890.davem@davemloft.net>
References: <20110213.105216.27797609.davem@davemloft.net>
	<20110213.110530.98884040.davem@davemloft.net>
	<D5ECB3C7A6F99444980976A8C6D896384DEE366783@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: bhupesh.sharma-qxv4g6HH51o@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEE366783-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Date: Mon, 14 Feb 2011 13:30:45 +0800

> I realized the problem happens when one compiles c_can files for x86 platform.
> As I have a ARM based platform, I get the "clk_get_rate", "clk_get" and
> "clk_put" definitions correctly when I perform the build operations.
> 
> Now there can be two approaches to solve this issue:
> 1. Restrict C_CAN build only for ARM based platforms by adding the
> dependency "depends on HAVE_CLK" in the Kconfig file for C_CAN.
> For e.g. see the I2C_DESIGNWARE case: 
> http://lxr.linux.no/linux+v2.6.31/drivers/i2c/busses/Kconfig#L329
> 
> 2. Add #if defined(CONFIG_HAVE_CLK) macros to protect this code in "c_can_platform.c"
> For e.g. see: http://lxr.linux.no/linux+v2.6.31/drivers/serial/sh-sci.c#L1085
> 
> IMHO, approach 2 seems better as it will allow C_CAN to work on x86 platforms
> as well which will suit Intel TopCliff platform also.
> 
> Please let me know your views on the same and I will send a v8 accordingly.

#2 is definitely better.
