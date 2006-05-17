From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Gianfar SKB Recycling Support
Date: Thu, 18 May 2006 00:55:30 +0200
Message-ID: <200605180055.31051.ak@suse.de>
References: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:32450 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750843AbWEQWzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 18:55:47 -0400
To: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
In-Reply-To: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 18 May 2006 00:45, Haruki Dai-r35557 wrote:
> This patch improves the IP forwarding throughput of
> the Freescale TSEC/eTSEC Gianfar driver. By recycling
> the Socket buffer and Data buffer, reduce the unnecessary
> memory allocation and de-allocation in the forwarding
> processing chain.

Seems very hackish because it only works inside the driver. 

Also  there is a reason why Linux doesn't support this normally - 
it wrecks the unified memory management because you won't free
your pools on memory pressure.

-Andi
