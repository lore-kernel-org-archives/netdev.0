From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] can: provide library functions for skb allocation
Date: Tue, 20 Oct 2009 08:43:11 +0200
Message-ID: <4ADD5BFF.6050308@grandegger.com>
References: <4ADB6243.2040109@grandegger.com>	<20091019.215440.256002623.davem@davemloft.net>
	<20091019.230549.29520350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20091019.230549.29520350.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Mon, 19 Oct 2009 21:54:40 -0700 (PDT)
> 
>> Applied, thanks.
> 
> Actually I have to back this out, you have to add an extern
> declaration for these public functions to a header the CAN
> drivers will see, or else there'll be build warnings and
> errors.
> 
> I wonder if you actually did this, but forgot that part of
> the change or lost it somehow while respinning this.

Already the original patch was incomplete and I obviously forgot to
compile test it. I was sure that I did that already, but, well, sorry
for the inconvenience caused.

> Please fix this up and resubmit, thanks.

Will resubmit in a second.

Thanks,

Wolfgang.
