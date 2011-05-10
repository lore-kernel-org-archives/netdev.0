From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Mon, 09 May 2011 17:15:26 -0700
Message-ID: <1304986526.19586.80.camel@Joe-Laptop>
References: <20110510000758.GA12728@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: aquini@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1414 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755765Ab1EJAP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 20:15:28 -0400
In-Reply-To: <20110510000758.GA12728@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 21:08 -0300, Rafael Aquini wrote:
>  drivers/net/bonding/bond_3ad.c |  886 +++++++++++++++++++++++-----------------
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> @@ -411,36 +407,37 @@ static inline void __initialize_port_locks(struct port *port)
>   */
>  static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
>  {
> -	u16 retval = 0; /* to silence the compiler */
> +	u16 uninitialized_var(retval);

uninitialized_var isn't necessary.  Every case will set retval.

>  	switch (timer_type) {
[]
> +	default:
> +		/* Exception: unexpected timer_type received */
> +		pr_debug("Unexpected AD timer_type: %d\n", timer_type);
> +		retval = 0;
> +		break;
>  	}
>  	return retval;
>  }


