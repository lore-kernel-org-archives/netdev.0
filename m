From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: 32bit DMA for ASUS A8N-SLI Premium
Date: Fri, 26 Nov 2010 10:52:33 -0800
Message-ID: <20101126105233.091f818d@nehalam>
References: <4CEFBB72.2060400@fremnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shannon Wynter <kernel.org.alias@fremnet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36543 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754497Ab0KZSxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 13:53:21 -0500
In-Reply-To: <4CEFBB72.2060400@fremnet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Nov 2010 23:51:46 +1000
Shannon Wynter <kernel.org.alias@fremnet.net> wrote:

> Add ASUS A8N-SLI Premium to the list of boards that require the quirk to
> limit DMA to 32bit in the skge.c module.
> 
> Signed-off-by: Shannon Wynter <kernel.org.alias@fremnet.net>
> ---
> --- a/drivers/net/skge.c	2010-11-26 08:35:21.000000000 +1000
> +++ b/drivers/net/skge.c	2010-11-26 08:58:52.000000000 +1000
> @@ -4158,6 +4158,13 @@
>   			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
>   		},
>   	},
> +	{
> +		.ident = "ASUSTeK A8N-SLI Premium",
> +		.matches = {
> +			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
> +			DMI_MATCH(DMI_BOARD_NAME, "A8N-SLI Premium"),
> +		},
> +	},
>   	{}
>   };
> 
> 

Ok. Maybe I have to buy one of these beasts to find the root
cause of this.

-- 
