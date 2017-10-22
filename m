From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc_close: mark expected switch fall-throughs
Date: Sun, 22 Oct 2017 02:08:35 +0100 (WEST)
Message-ID: <20171022.020835.2065879880300400886.davem@davemloft.net>
References: <20171019220244.GA22041@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019220244.GA22041@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 19 Oct 2017 17:02:44 -0500

> @@ -360,7 +360,8 @@ static void smc_close_passive_work(struct work_struct *work)
>  	case SMC_PEERCLOSEWAIT1:
>  		if (rxflags->peer_done_writing)
>  			sk->sk_state = SMC_PEERCLOSEWAIT2;
> -		/* fall through to check for closing */
> +		/* to check for closing */
> +		/* fall through */

Gustavo please look at what you are doing to the code.

This was a nice easy to read sentence in the comment, and now
you've chopped it up into two pieces and made it awkward and
more difficult to read.
