From: Andrew Jones <drjones@redhat.com>
Subject: Re: [PATCH V8 1/3] irq: Add flags to request_percpu_irq function
Date: Mon, 27 Mar 2017 10:44:42 +0200
Message-ID: <20170327084442.xdosrvdzh2pvn7xa@kamzik.brq.redhat.com>
References: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nicolas.pitre@linaro.org, linux-samsung-soc@vger.kernel.org,
 vincent.guittot@linaro.org, kernel@stlinux.com, kvm@vger.kernel.org,
 rafael@kernel.org, peterz@infradead.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
 tglx@linutronix.de, linux-snps-arc@lists.infradead.org,
 kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
To: Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <kvmarm-bounces@lists.cs.columbia.edu>
Content-Disposition: inline
In-Reply-To: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
List-Unsubscribe: <https://lists.cs.columbia.edu/mailman/options/kvmarm>,
 <mailto:kvmarm-request@lists.cs.columbia.edu?subject=unsubscribe>
List-Archive: <https://lists.cs.columbia.edu/pipermail/kvmarm>
List-Post: <mailto:kvmarm@lists.cs.columbia.edu>
List-Help: <mailto:kvmarm-request@lists.cs.columbia.edu?subject=help>
List-Subscribe: <https://lists.cs.columbia.edu/mailman/listinfo/kvmarm>,
 <mailto:kvmarm-request@lists.cs.columbia.edu?subject=subscribe>
Errors-To: kvmarm-bounces@lists.cs.columbia.edu
Sender: kvmarm-bounces@lists.cs.columbia.edu
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 06:42:01PM +0100, Daniel Lezcano wrote:
> diff --git a/drivers/clocksource/timer-nps.c b/drivers/clocksource/timer-nps.c
> index da1f798..dbdb622 100644
> --- a/drivers/clocksource/timer-nps.c
> +++ b/drivers/clocksource/timer-nps.c
> @@ -256,7 +256,7 @@ static int __init nps_setup_clockevent(struct device_node *node)
>  		return ret;
>  
>  	/* Needs apriori irq_set_percpu_devid() done in intc map function */
> -	ret = request_percpu_irq(nps_timer0_irq, timer_irq_handler,
> +	ret = request_percpu_irq(nps_timer0_irq, timer_irq_handler, IRQF_TIMER,
>  				 "Timer0 (per-cpu-tick)",
>  				 &nps_clockevent_device);

Wrong parameter order here.

drew
