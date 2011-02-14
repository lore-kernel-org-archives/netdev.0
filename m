From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Subject: RE: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Mon, 14 Feb 2011 13:30:45 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DEE366783@EAPEX1MAIL1.st.com>
References: <1297419478-27667-1-git-send-email-bhupesh.sharma@st.com>
	<4D56C0ED.1040201@pengutronix.de>
	<20110213.105216.27797609.davem@davemloft.net>
	<20110213.110530.98884040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Language: en-US
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

Hi David,

> -----Original Message-----
> From: Bhupesh SHARMA
> Sent: Monday, February 14, 2011 9:25 AM
> To: 'David Miller'; mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Subject: RE: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for
> Bosch C_CAN controller
> 
> Hi David,
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> > Sent: Monday, February 14, 2011 12:36 AM
> > To: mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
> > Cc: Bhupesh SHARMA; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Socketcan-
> > core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> > Subject: Re: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support
> for
> > Bosch C_CAN controller
> >
> > From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > Date: Sun, 13 Feb 2011 10:52:16 -0800 (PST)
> >
> > > From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > > Date: Sat, 12 Feb 2011 18:18:37 +0100
> > >
> > >> On 02/11/2011 11:17 AM, Bhupesh Sharma wrote:
> > >>> Bosch C_CAN controller is a full-CAN implementation which is
> > compliant
> > >>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual
> > can be
> > >>> obtained from:
> > >>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> > >>> c_can/users_manual_c_can.pdf
> > >>>
> > >>> This patch adds the support for this controller.
> > >>> The following are the design choices made while writing the
> > controller
> > >>> driver:
> > >>> 1. Interface Register set IF1 has be used only in the current
> > design.
> > >>> 2. Out of the 32 Message objects available, 16 are kept aside for
> > RX
> > >>>    purposes and the rest for TX purposes.
> > >>> 3. NAPI implementation is such that both the TX and RX paths
> > function
> > >>>    in polling mode.
> > >>>
> > >>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> > >>
> > >> Good work!
> > >>
> > >> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > >
> > > Applied.
> >
> > Actually, I'm reverting because this causes build regressions:
> >
> > ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_platform.ko]
> > undefined!
> > ERROR: "clk_get" [drivers/net/can/c_can/c_can_platform.ko] undefined!
> > ERROR: "clk_put" [drivers/net/can/c_can/c_can_platform.ko] undefined!
> 
> Oops.. I will send a v8 to correct this compilation issue a.s.a.p.
> 

I realized the problem happens when one compiles c_can files for x86 platform.
As I have a ARM based platform, I get the "clk_get_rate", "clk_get" and
"clk_put" definitions correctly when I perform the build operations.

Now there can be two approaches to solve this issue:
1. Restrict C_CAN build only for ARM based platforms by adding the
dependency "depends on HAVE_CLK" in the Kconfig file for C_CAN.
For e.g. see the I2C_DESIGNWARE case: 
http://lxr.linux.no/linux+v2.6.31/drivers/i2c/busses/Kconfig#L329

2. Add #if defined(CONFIG_HAVE_CLK) macros to protect this code in "c_can_platform.c"
For e.g. see: http://lxr.linux.no/linux+v2.6.31/drivers/serial/sh-sci.c#L1085

IMHO, approach 2 seems better as it will allow C_CAN to work on x86 platforms
as well which will suit Intel TopCliff platform also.

Please let me know your views on the same and I will send a v8 accordingly.

Regards,
Bhupesh
