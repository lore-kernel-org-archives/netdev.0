From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next 6/7] ipv4: ERROR: code indent should use tabs
 where possible
Date: Fri, 20 Dec 2013 17:53:06 +0000
Message-ID: <1387561986.1549.9.camel@bwh-desktop.uk.level5networks.com>
References: <1387540630-11052-1-git-send-email-chenweilong@huawei.com>
	 <1387540630-11052-7-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1387540630-11052-7-git-send-email-chenweilong@huawei.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-12-20 at 19:57 +0800, Chen Weilong wrote:
> From: Weilong Chen <chenweilong@huawei.com>
> 
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> ---
>  net/ipv4/cipso_ipv4.c      | 6 +++---
>  net/ipv4/sysctl_net_ipv4.c | 2 +-
>  net/ipv4/xfrm4_mode_beet.c | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index 4b59b6e..081f51a 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1336,7 +1336,7 @@ static int cipso_v4_parsetag_rbm(const struct cipso_v4_doi *doi_def,
>  
>  	if (tag_len > 4) {
>  		secattr->attr.mls.cat =
> -		                       netlbl_secattr_catmap_alloc(GFP_ATOMIC);
> +				       netlbl_secattr_catmap_alloc(GFP_ATOMIC);
>  		if (secattr->attr.mls.cat == NULL)
>  			return -ENOMEM;
>  
> @@ -1432,7 +1432,7 @@ static int cipso_v4_parsetag_enum(const struct cipso_v4_doi *doi_def,
>  
>  	if (tag_len > 4) {
>  		secattr->attr.mls.cat =
> -			               netlbl_secattr_catmap_alloc(GFP_ATOMIC);
> +				       netlbl_secattr_catmap_alloc(GFP_ATOMIC);
>  		if (secattr->attr.mls.cat == NULL)
>  			return -ENOMEM;
>  
> @@ -1527,7 +1527,7 @@ static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
>  
>  	if (tag_len > 4) {
>  		secattr->attr.mls.cat =
> -			               netlbl_secattr_catmap_alloc(GFP_ATOMIC);
> +				       netlbl_secattr_catmap_alloc(GFP_ATOMIC);
>  		if (secattr->attr.mls.cat == NULL)
>  			return -ENOMEM;
>  
[...]

These lines are still excessively indented (one extra tab is enough),
and could just be appended to the lines above them:

		secattr->attr.mls.cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);

(exactly 80 columns long).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

