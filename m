From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/9] rcu: Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x, NULL) in drivers/net/ethernet/broadcom/bnx2.c
Date: Tue, 18 Mar 2014 16:28:44 -0700
Message-ID: <20140318232844.GA4420@linux.vnet.ibm.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
 <1965df1cea51fc4c08e563554739fb74bbcaf58e.1395182132.git.monamagarwal123@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1965df1cea51fc4c08e563554739fb74bbcaf58e.1395182132.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 04:10:42AM +0530, Monam Agarwal wrote:
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  drivers/net/ethernet/broadcom/bnx2.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 965c723..5eab730 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -409,7 +409,7 @@ static int bnx2_unregister_cnic(struct net_device *dev)
>  	mutex_lock(&bp->cnic_lock);
>  	cp->drv_state = 0;
>  	bnapi->cnic_present = 0;
> -	rcu_assign_pointer(bp->cnic_ops, NULL);
> +	RCU_INIT_POINTER(bp->cnic_ops, NULL);
>  	mutex_unlock(&bp->cnic_lock);
>  	synchronize_rcu();
>  	return 0;
> -- 
> 1.7.9.5
> 
