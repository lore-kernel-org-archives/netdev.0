From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] net: netfilter: Remove typedef from "typedef struct
 field_t"
Date: Thu, 6 Apr 2017 18:26:54 +0200
Message-ID: <20170406162654.GA5777@salvia>
References: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
 <20170325122756.8743-2-arushisinghal19971997@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        outreachy-kernel@googlegroups.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170325122756.8743-2-arushisinghal19971997@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 25, 2017 at 05:57:55PM +0530, Arushi Singhal wrote:
> This patch removes typedefs from struct and renames it from "typedef struct
> field_t" to "struct field" as per kernel coding standards."
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  net/netfilter/nf_conntrack_h323_asn1.c | 68 +++++++++++++++++-----------------
>  1 file changed, 34 insertions(+), 34 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
> index 89b2e46925c4..fb8cf238a76f 100644
> --- a/net/netfilter/nf_conntrack_h323_asn1.c
> +++ b/net/netfilter/nf_conntrack_h323_asn1.c
> @@ -77,7 +77,7 @@
>  
>  
>  /* ASN.1 Field Structure */
> -typedef struct field_t {
> +struct field {

Probably better if you rename this to 'struct h323_field' to make sure
compilation doesn't break due to structure name pollution. And we also
got a report from kbuild robot that would be good to investigate.
