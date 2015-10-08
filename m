From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] netfilter: fix bad checksum on IPv6 when NAT is
 performed
Date: Thu, 08 Oct 2015 22:19:47 +0200
Message-ID: <1444335587.14655.387.camel@sakura.staff.proxad.net>
References: <1444141425.14655.341.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, kaber <kaber@trash.net>,
	pablo@netfilter.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444141425.14655.341.camel@sakura.staff.proxad.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2015-10-06 at 16:23 +0200, Maxime Bizon wrote:

> +	if (maniptype == NF_NAT_MANIP_SRC) {
> +		from = ipv6h->saddr.s6_addr32;
> +		to = target->src.u3.in6.s6_addr32;
> +	} else {
> +		from = ipv6h->daddr.s6_addr32;
> +		to = target->src.u3.in6.s6_addr32;
> +	}

stupid copy & paste error here, will send v2

-- 
Maxime


