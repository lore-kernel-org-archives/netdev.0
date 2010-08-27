From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] sky2: Add unidirectional fiber link support
Date: Fri, 27 Aug 2010 13:38:25 -0700
Message-ID: <20100827133825.494b8098@nehalam>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
	<1282938138-17844-3-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Kyle Moffett <kyle@moffetthome.net>,
	netdev@vger.kernel.org
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282938138-17844-3-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Aug 2010 15:42:18 -0400
Kyle Moffett <Kyle.D.Moffett@boeing.com> wrote:

> +	/* 
> +	 * Once interrupts are reenabled, reset the PHY again to make sure
> +	 * that we didn't miss a link-up interrupt.  This is especially
> +	 * likely to occur if we're in fiber-txonly mode, as a link-up
> +	 * interrupt is generated almost immediately after we finish
> +	 * programming the PHY.
> +	 */
> +	sky2_phy_reinit(sky2);

Won't this cause a renegotiation causing up to 2 second delay?

-- 
