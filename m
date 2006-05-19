From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Gianfar SKB Recycling Support
Date: Fri, 19 May 2006 10:47:57 -0700
Message-ID: <20060519104757.41a5da9a@localhost.localdomain>
References: <18AEF66AFDF06F4CAAA1D419D000FD33524B79@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>,
	"Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30443 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751410AbWESRsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 13:48:01 -0400
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

In case the general impression wasn't clear from the earlier comments.
This patch is an interesting benchmark tweak, but unlikely to ever
make it into the mainline kernel. The kernel needs to be a general
purpose system and deal with multiple types of hardware and resource
control.

But don't give up looking at performance. If you can find ways to
speed up the overall socket buffer handling without breaking existing
semantics; then the patches would be positively received.
