From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/31: netfilter update
Date: Fri, 12 Jun 2009 01:47:22 +0200
Message-ID: <4A31978A.3040300@trash.net>
References: <4A310C9E.3050904@trash.net>	<4A311AB9.3060205@trash.net>	<20090611.161910.109357779.davem@davemloft.net> <20090611.164047.74924409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090611.164047.74924409.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 11 Jun 2009 16:19:10 -0700 (PDT)
> Nevermind, still broken:
>
> net/ipv4/netfilter/ip_tables.c: In function 'ipt_do_table':
> net/ipv4/netfilter/ip_tables.c:421: error: 'comefrom' undeclared (first use in this function)
> net/ipv4/netfilter/ip_tables.c:421: error: (Each undeclared identifier is reported only once
> net/ipv4/netfilter/ip_tables.c:421: error: for each function it appears in.)
>
> You're not testing what you're sending to me.
>   

Appologies again, I didn't test CONFIG_NETFILTER_DEBUG=y.
I'll fix it up and do a few more compile tests myself.

