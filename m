From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: DMA Quirks for skge.c
Date: Fri, 26 Nov 2010 10:21:02 +0100
Message-ID: <20101126092059.GA2628@redhat.com>
References: <4CEF565A.6060803@jumbolotteries.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Shannon Wynter <shannonw@jumbolotteries.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866Ab0KZJVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 04:21:43 -0500
Content-Disposition: inline
In-Reply-To: <4CEF565A.6060803@jumbolotteries.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

(cc Stephen and netdev)

On Fri, Nov 26, 2010 at 04:40:26PM +1000, Shannon Wynter wrote:
> Hi there.
> 
> I truly thank you for resolving the problem with the Gigabyte board
> as without your fix I never would have been able to pinpoint the
> issue I was having with my network card after upgrading my memory.
> 
> I submit to you a patch that adds the ASUS A8N-SLI Premium board to
> the list of poorly built boards.
> 
> I do wonder if it might be an idea to also add a module parameter
> that forces 32 bit.

Maybe for debug purposes it will be useful, but I dislike situation when
users have to use module options to make hardware work. Anyway Stephen
said that he works on better solution for that problem ... 

> Kind regards
> 
> Shannon

> diff -uNr linux-2.6.37-rc3.old/drivers/net/skge.c linux-2.6.37-rc3.new//drivers/net/skge.c
> --- linux-2.6.37-rc3.old/drivers/net/skge.c	2010-11-26 08:35:21.000000000 +1000
> +++ linux-2.6.37-rc3.new//drivers/net/skge.c	2010-11-26 08:58:52.000000000 +1000
> @@ -4158,6 +4158,13 @@
>  			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
>  		},
>  	},
> +	{
> +		.ident = "ASUSTeK A8N-SLI Premium",
> +		.matches = {
> +			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
> +			DMI_MATCH(DMI_BOARD_NAME, "A8N-SLI Premium"),
> +		},
> +	},
>  	{}
>  };

Add Signed-off-by line and repost patch according to MAINTAINERS
file (to Stephen and netdev).

Thanks
Stanislaw
