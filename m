From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Gianfar SKB Recycling Support
Date: Wed, 17 May 2006 15:49:15 -0700
Message-ID: <20060517154915.4feb6e0e@localhost.localdomain>
References: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>,
	"Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30413 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751017AbWEQWtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 18:49:18 -0400
To: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
In-Reply-To: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 May 2006 15:45:14 -0700
"Haruki Dai-r35557" <Dai.Haruki@freescale.com> wrote:

> This patch improves the IP forwarding throughput of
> the Freescale TSEC/eTSEC Gianfar driver. By recycling
> the Socket buffer and Data buffer, reduce the unnecessary
> memory allocation and de-allocation in the forwarding
> processing chain.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> 

What if I am forwarding from gianfar to e1000?
