From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/9] rcu: Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x, NULL)
Date: Tue, 18 Mar 2014 16:29:56 -0700
Message-ID: <20140318232956.GD4420@linux.vnet.ibm.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
 <dfae0194a7fa12d09826ec79bbd7cecd132c7f8d.1395182132.git.monamagarwal123@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dfae0194a7fa12d09826ec79bbd7cecd132c7f8d.1395182132.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 04:15:44AM +0530, Monam Agarwal wrote:
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  drivers/net/ppp/pptp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index 89f829f..ede899c 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -162,7 +162,7 @@ static void del_chan(struct pppox_sock *sock)
>  {
>  	spin_lock(&chan_lock);
>  	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
> -	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
> +	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
>  	spin_unlock(&chan_lock);
>  	synchronize_rcu();
>  }
> -- 
> 1.7.9.5
> 
