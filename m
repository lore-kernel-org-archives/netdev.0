From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Mon, 03 Jan 2011 09:33:27 -0800 (PST)
Message-ID: <20110103.093327.104057155.davem@davemloft.net>
References: <20101224091428.GA375@e-circ.dyndns.org>
	<4D148788.3010808@pengutronix.de>
	<20110103163835.GD320@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: kurt.van.dijck-/BeEPy95v10@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110103163835.GD320-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Date: Mon, 3 Jan 2011 17:38:35 +0100

> On Fri, Dec 24, 2010 at 12:44:08PM +0100, Marc Kleine-Budde wrote:
>> 
>> >> hmmm..all stuff behind dpram is __iomem, isn't it? I think it should
>> >> only be accessed with via the ioread/iowrite operators. Please check
>> > I did an ioremap_nocache. Since it is unaligned, ioread/iowrite would render
>> > a lot of statements.
>> 
>> The thing is, ioremapped mem should not be accessed directly. Instead
>> ioread/iowrite should be used. The softing driver should work on non x86
>> platforms, too.
>> 
> I use __attribute__((packed)) structs to refer to the iomemory.
> To read an unaligned uint16_t, is should then use 2 readb()'s ??
> 
> I could of course turn that sequence into a macro ....

Yes, this is what you'll need to do.
