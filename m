From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Outreachy kernel] [PATCH] net: netfilter: Remove typedef from
 "typedef struct bitstr_t".
Date: Fri, 7 Apr 2017 00:52:06 +0200
Message-ID: <20170406225206.GA2714@salvia>
References: <20170328182413.GA14102@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170328182413.GA14102@arushi-HP-Pavilion-Notebook>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 11:54:13PM +0530, Arushi Singhal wrote:
> This patch removes typedefs from struct and renames it from "typedef struct
> bitstr_t" to "struct bitstr" as per kernel coding standards."
> 
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  net/netfilter/nf_conntrack_h323_asn1.c | 80 +++++++++++++++++-----------------
>  1 file changed, 40 insertions(+), 40 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
> index fb8cf238a76f..4502c0d6071d 100644
> --- a/net/netfilter/nf_conntrack_h323_asn1.c
> +++ b/net/netfilter/nf_conntrack_h323_asn1.c
> @@ -91,41 +91,41 @@ struct field {
>  };
>  
>  /* Bit Stream */
> -typedef struct {
> +struct bitstr {

Same thing here, I'd suggest you use 'struct h323_bitstr' instead.

Thanks!
