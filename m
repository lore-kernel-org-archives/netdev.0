From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [net 0/8] gianfar: ARM port driver updates (1/2)
Date: Fri, 3 Oct 2014 16:20:31 -0500
Message-ID: <20141003162031.2a9ae05c6d38402cd8e70298@freescale.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Xiubo Li" <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0136.outbound.protection.outlook.com ([65.55.169.136]:9984
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750850AbaJCVZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 17:25:47 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Oct 2014 19:02:41 +0300
Claudiu Manoil <claudiu.manoil@freescale.com> wrote:

> Claudiu Manoil (8):
>   net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
>   net/fsl_pq_mdio: Use ioread/iowrite32be() portable accessors
>   net/fsl_pq_mdio: Replace spin_event_timeout() with arch independent
>   gianfar: Include missing headers for ARM builds
>   gianfar: Exclude PPC specific errata handling from ARM builds
>   gianfar: Make MAC addr setup endian safe, cleanup
>   gianfar: Replace spin_event_timeout() with arch independent
>   gianfar: Replace eieio with wmb for non-PPC archs
> 
>  drivers/net/ethernet/freescale/fsl_pq_mdio.c | 56 ++++++++++++++---------
>  drivers/net/ethernet/freescale/gianfar.c     | 68 +++++++++++++++-------------
>  drivers/net/ethernet/freescale/gianfar.h     | 31 +++++++++++++
>  3 files changed, 102 insertions(+), 53 deletions(-)

this series:

Reviewed-by: Kim Phillips <kim.phillips@freescale.com>

Thanks,

Kim
