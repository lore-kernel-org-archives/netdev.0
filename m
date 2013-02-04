From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] Doc: percpu_counter doc code for better readability
Date: Mon, 4 Feb 2013 13:49:52 -0800
Message-ID: <20130204214952.GJ27963@mtj.dyndns.org>
References: <20130129083156.20701.33948.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130129083156.20701.33948.stgit@dragon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 29, 2013 at 09:31:56AM +0100, Jesper Dangaard Brouer wrote:
> Help people reading the percpu_counter code, to notice the ifdef
> else statement that seperates CONFIG_SMP.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/linux/percpu_counter.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> index b9df9ed..eded1aa 100644
> --- a/include/linux/percpu_counter.h
> +++ b/include/linux/percpu_counter.h
> @@ -83,7 +83,7 @@ static inline int percpu_counter_initialized(struct percpu_counter *fbc)
>  	return (fbc->counters != NULL);
>  }
>  
> -#else
> +#else /* No CONFIG_SMP */

"#else /* !CONFIG_SMP */" would be more conventional.  Can you please
change that and repost it w/ my Acked-by and [TRIVIAL] tag added and
Jiri Kosina <trivial@kernel.org> cc'd?

Thanks.

-- 
tejun
