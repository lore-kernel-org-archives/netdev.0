From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/8] net: thunderx: Rework interrupt handler
Date: Fri, 28 Aug 2015 14:26:40 -0700 (PDT)
Message-ID: <20150828.142640.647193074690125620.davem@davemloft.net>
References: <1440774004-27923-1-git-send-email-aleksey.makarov@auriga.com>
	<1440774004-27923-6-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, david.daney@cavium.com,
	robert.richter@caviumnetworks.com,
	Sunil.Goutham@caviumnetworks.com, sgoutham@cavium.com,
	aleksey.makarov@caviumnetworks.com, rric@kernel.org
To: aleksey.makarov@auriga.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440774004-27923-6-git-send-email-aleksey.makarov@auriga.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aleksey Makarov <aleksey.makarov@auriga.com>
Date: Fri, 28 Aug 2015 17:59:58 +0300

> @@ -251,6 +251,8 @@ struct cmp_queue {
>  	void		*desc;
>  	struct q_desc_mem   dmem;
>  	struct cmp_queue_stats	stats;
> +	int		irq;
> +	cpumask_t	affinity_mask;
>  } ____cacheline_aligned_in_smp;
>  
>  struct snd_queue {

This new "affinity_mask" member is not used, please remove it and respin
this patch series.

Thanks.
