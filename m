From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RT] net: move xmit_recursion to per-task variable on
 -RT
Date: Wed, 13 Jan 2016 18:31:46 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601131830440.3575@nanos>
References: <20160113152352.GH29964@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113152352.GH29964@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jan 2016, Sebastian Andrzej Siewior wrote:
> +#ifdef CONFIG_PREEMPT_RT_FULL
> +static inline int dev_recursion_level(void)
> +{
> +	return atomic_read(&current->xmit_recursion);

Why would you need an atomic here. current does hardly race against itself.

Thanks,

	tglx
