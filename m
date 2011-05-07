From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Fri, 06 May 2011 18:51:40 -0700
Message-ID: <1304733100.11874.33.camel@Joe-Laptop>
References: <20110507012717.GA15854@x61.tchesoft.com>
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
Received: from mail.perches.com ([173.55.12.10]:1306 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab1EGBvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 21:51:41 -0400
In-Reply-To: <20110507012717.GA15854@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-06 at 22:27 -0300, Rafael Aquini wrote:
> @@ -411,36 +406,32 @@ static inline void __initialize_port_locks(struct port *port)
>   */
>  static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
>  {
> -	u16 retval = 0; /* to silence the compiler */
> +	u16 retval = 0;

I think it's not good to remove this sort of comment.
(there are others like it)

Another option might be to add __maybe_unused


