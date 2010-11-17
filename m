From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4] can: Topcliff: PCH_CAN driver: Add Flow
	control/Fix Endianess issue/Separate IF register/Enumerate LEC
	macro/Move MSI processing/Use BIT(X)/Change Message Object
	index/Add prefix PCH_
Date: Wed, 17 Nov 2010 12:00:37 +0900
Message-ID: <00d101cb8603$9e2f3970$66f8800a@maildom.okisemi.com>
References: <4CE2EC13.9090707@grandegger.com><20101116.124325.116396459.davem@davemloft.net><20101116210716.GA19893@pengutronix.de>
	<20101116.131008.212663108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

Hi David Miller,

I see, I just have to obey your saying.
I will split our patch per issue/indicated item and re-submit to you.

Thanks,
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
----- Original Message ----- 
From: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>; <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>;
<sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>;
<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>;
<chripell-VaTbYqLCNhc@public.gmane.org>; <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sent: Wednesday, November 17, 2010 6:10 AM
Subject: Re: [PATCH net-next-2.6 v4] can: Topcliff: PCH_CAN driver: Add Flow control/Fix Endianess issue/Separate IF
register/Enumerate LEC macro/Move MSI processing/Use BIT(X)/Change Message Object index/Add prefix PCH_


> From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Date: Tue, 16 Nov 2010 22:07:16 +0100
>
> > On Tue, Nov 16, 2010 at 12:43:25PM -0800, David Miller wrote:
> >> From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> >> Date: Tue, 16 Nov 2010 21:39:47 +0100
> >>
> >> > Please take into account that this patch got accepted by accident
> >> > (because the maintainer did not respond properly in time). At that time
> >> > the driver was incomplete, not ready for mainline and did not even work
> >> > properly. Therefore it makes little sense to debug or even bisec these
> >> > changes. Just for that reason I made an exemption and added my
> >> > "Acked-by". Hope you can share my arguments.
> >>
> >> You don't put stupid on top of stupid and justify the latter using
> >> the former.
> >
> > Is reverting the incomplete driver an option?
>
> I told everyone that the plan was that we had several months
> to fix this, and that's what we should do.
>
> But yes if people are going to be maximally difficult about this and
> refuse to split up the bug fixes, I will have to regrettably revert
> the driver.
>
> But let's avoid that if we can.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
