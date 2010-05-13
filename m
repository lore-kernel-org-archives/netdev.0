From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next] net/: (netfilter related) Remove unnecessary
 returns from void function()s
Date: Thu, 13 May 2010 15:20:04 +0200
Message-ID: <4BEBFC84.5020707@trash.net>
References: <1273600346.20514.247.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273600346.20514.247.camel@Joe-Laptop.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> This patch removes from net/ netfilter files
> all the unnecessary return; statements that precede the
> last closing brace of void functions.
> 
> It does not remove the returns that are immediately
> preceded by a label as gcc doesn't like that.
> 
> Done via:
> $ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
>   xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'
> 

Applied, but I changed the patch to keep the two return statements
below in otherwise empty function bodies since I consider that more
aesthetically pleasing.

> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> @@ -452,6 +452,5 @@ module_exit(nf_conntrack_l3proto_ipv4_fini);
>  
>  void need_ipv4_conntrack(void)
>  {
> -	return;
>  }
>  EXPORT_SYMBOL_GPL(need_ipv4_conntrack);
> diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
> index d7e8920..39efbe6 100644
> --- a/net/ipv4/netfilter/nf_nat_proto_gre.c
> +++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
> @@ -144,6 +144,5 @@ module_exit(nf_nat_proto_gre_fini);
>  
>  void nf_nat_need_gre(void)
>  {
> -	return;
>  }
