From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 5/5] sctp: Adjust one function call together with a
 variable assignment
Date: Mon, 22 May 2017 16:53:09 -0300
Message-ID: <20170522195308.GG4642@localhost.localdomain>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <197333e8-b528-ef34-bd16-01e415acdf52@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <197333e8-b528-ef34-bd16-01e415acdf52@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 06:41:45PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 18:15:12 +0200
> 
> The script "checkpatch.pl" pointed information out like the following.
> 
> ERROR: do not use assignment in if condition
> 
> Thus fix the affected source code place.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/protocol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 057479b7bd72..be2fe3ebae78 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -141,7 +141,8 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
>  	struct sctp_sockaddr_entry *addr;
>  
>  	rcu_read_lock();
> -	if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
> +	in_dev = __in_dev_get_rcu(dev);
> +	if (!in_dev) {
>  		rcu_read_unlock();
>  		return;
>  	}
> -- 
> 2.13.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
