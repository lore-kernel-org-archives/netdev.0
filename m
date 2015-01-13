From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] mlx5: avoid build warnings on 32-bit
Date: Tue, 13 Jan 2015 21:25:46 +0100
Message-ID: <2673334.S7APmEAXNW@wuerfel>
References: <4105686.Jz5UR0277i@wuerfel> <20150113162803.GA7414@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150113162803.GA7414@mtldesk30>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 January 2015 18:28:03 Eli Cohen wrote:
> On Tue, Jan 13, 2015 at 05:08:06PM +0100, Arnd Bergmann wrote:
> 
> Hi Arnd,
> wouldn't it work by casting to uintptr_t instead of unsigned long?
> 

These are the same on all architectures that Linux can run on,
but if you have a strong preference, I can send an updated
patch, the effect is exactly the same.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
