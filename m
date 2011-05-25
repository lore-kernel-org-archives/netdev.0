From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 28/34] atm: Drop __TIME__ usage
Date: Wed, 25 May 2011 22:49:29 +0200
Message-ID: <4DDD6B59.9000108@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-29-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-29-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 5.4.2011 16:59, Michal Marek napsal(a):
> The kernel already prints its build timestamp during boot, no need to
> repeat it in random drivers and produce different object files each
> time.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>
> ---
>  net/atm/lec.c |    2 +-
>  net/atm/mpc.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Hi,

I don't see this patch in today's linux-next. Any objection against me
applying it to the kbuild-2.6.git repository?

Thanks,
Michal


> diff --git a/net/atm/lec.c b/net/atm/lec.c
> index 38754fd..cb14ddf 100644
> --- a/net/atm/lec.c
> +++ b/net/atm/lec.c
> @@ -1173,7 +1173,7 @@ static int __init lane_module_init(void)
>  #endif
>  
>  	register_atm_ioctl(&lane_ioctl_ops);
> -	pr_info("lec.c: " __DATE__ " " __TIME__ " initialized\n");
> +	pr_info("lec.c: initialized\n");
>  	return 0;
>  }
>  
> diff --git a/net/atm/mpc.c b/net/atm/mpc.c
> index 644cdf0..3ccca42 100644
> --- a/net/atm/mpc.c
> +++ b/net/atm/mpc.c
> @@ -1482,7 +1482,7 @@ static __init int atm_mpoa_init(void)
>  	if (mpc_proc_init() != 0)
>  		pr_info("failed to initialize /proc/mpoa\n");
>  
> -	pr_info("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
> +	pr_info("mpc.c: initialized\n");
>  
>  	return 0;
>  }

