From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipx: replace long unsigned int by
 unsigned long
Date: Mon, 27 Oct 2014 15:46:21 -0400 (EDT)
Message-ID: <20141027.154621.543894481047212079.davem@davemloft.net>
References: <1414433133-29161-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414433133-29161-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 27 Oct 2014 19:05:33 +0100

> @@ -90,7 +90,7 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
>  	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
>  	if (rt->ir_routed)
>  		seq_printf(seq, "%08lX     %02X%02X%02X%02X%02X%02X\n",
> -			   (long unsigned int)ntohl(rt->ir_intrfc->if_netnum),
> +			   (unsigned long)ntohl(rt->ir_intrfc->if_netnum),

How about we kill the silly cast altogether and use plain %08X?

Thanks.
