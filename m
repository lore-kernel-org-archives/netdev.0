From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH][net-next] net: mpls: make function ipgre_mpls_encap_hlen
 static
Date: Wed, 11 Oct 2017 08:12:34 -0600
Message-ID: <282bd0a3-4cf6-4269-c07f-a476aa0bb764@gmail.com>
References: <20171011095328.17546-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        Amine Kherbouche <amine.kherbouche@6wind.com>
To: Colin King <colin.king@canonical.com>,
        "David S . Miller" <davem@davemloft.net>,
        Robert Shearman <rshearma@brocade.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011095328.17546-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/17 3:53 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The function ipgre_mpls_encap_hlen is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'ipgre_mpls_encap_hlen' was not declared. Should it be static?
> 
Fixes: bdc476413dcdb ("ip_tunnel: add mpls over gre support")

> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/mpls/af_mpls.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 9745e8f69810..8ca9915befc8 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -41,7 +41,7 @@ static int label_limit = (1 << 20) - 1;
>  static int ttl_max = 255;
>  
>  #if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
> -size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
> +static size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
>  {
>  	return sizeof(struct mpls_shim_hdr);
>  }
> 

 Acked-by: David Ahern <dsahern@gmail.com>
