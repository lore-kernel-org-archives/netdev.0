From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 net-next] ipx: replace long unsigned int by unsigned
 long
Date: Mon, 27 Oct 2014 11:22:11 -0700
Message-ID: <1414434131.18896.4.camel@perches.com>
References: <1414433133-29161-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414433133-29161-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-27 at 19:05 +0100, Fabian Frederick wrote:
> Use standard unsigned long.
[]
> diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
[]
> @@ -90,7 +90,7 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
>  	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
>  	if (rt->ir_routed)
>  		seq_printf(seq, "%08lX     %02X%02X%02X%02X%02X%02X\n",
> -			   (long unsigned int)ntohl(rt->ir_intrfc->if_netnum),
> +			   (unsigned long)ntohl(rt->ir_intrfc->if_netnum),

Maybe better to use no cast at all

		seq_printf(seq, "%08X     %02X%02X%02X%02X%02X%02X\n",
			   ntohl(etc...),
