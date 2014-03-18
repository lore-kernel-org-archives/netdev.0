From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] rcu: Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x, NULL) in drivers/input/endev.c
Date: Tue, 18 Mar 2014 15:16:25 -0700
Message-ID: <20140318221625.GU4420@linux.vnet.ibm.com>
References: <1395179920-18392-1-git-send-email-monamagarwal123@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395179920-18392-1-git-send-email-monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 03:28:39AM +0530, Monam Agarwal wrote:
> This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/input/endev.c
> 
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  drivers/input/evdev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/input/evdev.c b/drivers/input/evdev.c
> index 4cf2534..92e7a3c 100644
> --- a/drivers/input/evdev.c
> +++ b/drivers/input/evdev.c
> @@ -174,7 +174,7 @@ static int evdev_ungrab(struct evdev *evdev, struct evdev_client *client)
>  	if (evdev->grab != client)
>  		return  -EINVAL;
> 
> -	rcu_assign_pointer(evdev->grab, NULL);
> +	RCU_INIT_POINTER(evdev->grab, NULL);
>  	synchronize_rcu();
>  	input_release_device(&evdev->handle);
> 
> -- 
> 1.7.9.5
> 
