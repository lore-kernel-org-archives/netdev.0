From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 12/12] sctp: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:36 -0400
Message-ID: <52409268.1050602@gmail.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com> <6738b115d30d40f33c688863f5421d84d2aa706c.1379961014.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6738b115d30d40f33c688863f5421d84d2aa706c.1379961014.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2013 02:37 PM, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>
> Signed-off-by: Joe Perches <joe@perches.com>

looks simple enough.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>


-vlad
> ---
>   include/net/sctp/sctp.h | 13 ++++++-------
>   1 file changed, 6 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 3794c5a..c5fe806 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -90,12 +90,11 @@
>   /*
>    * sctp/protocol.c
>    */
> -extern int sctp_copy_local_addr_list(struct net *, struct sctp_bind_addr *,
> -				     sctp_scope_t, gfp_t gfp,
> -				     int flags);
> -extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
> -extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
> -extern void sctp_addr_wq_mgmt(struct net *, struct sctp_sockaddr_entry *, int);
> +int sctp_copy_local_addr_list(struct net *, struct sctp_bind_addr *,
> +			      sctp_scope_t, gfp_t gfp, int flags);
> +struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
> +int sctp_register_pf(struct sctp_pf *, sa_family_t);
> +void sctp_addr_wq_mgmt(struct net *, struct sctp_sockaddr_entry *, int);
>
>   /*
>    * sctp/socket.c
> @@ -110,7 +109,7 @@ void sctp_sock_rfree(struct sk_buff *skb);
>   void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>   		    struct sctp_association *asoc);
>   extern struct percpu_counter sctp_sockets_allocated;
> -extern int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
> +int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
>
>   /*
>    * sctp/primitive.c
>
