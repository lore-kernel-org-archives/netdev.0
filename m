From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Adding Agile-SD TCP module and modifying Kconfig and
 Makefile to configure the kernel for this new module to configure the
 kernel for this new module.
Date: Tue, 1 Aug 2017 07:49:31 -0700
Message-ID: <20170801074931.34102262@xeon-e3>
References: <20170801095005.16025-1-mohamed.asnd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
        mohamed.a.alrshah@ieee.org
To: mohamedalrshah <mohamed.asnd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801095005.16025-1-mohamed.asnd@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  1 Aug 2017 17:50:05 +0800
mohamedalrshah <mohamed.asnd@gmail.com> wrote:

> From: Mohamed Alrshah <mohamed.asnd@gmail.com>
> 

Please add more background on Agile-SD in the email commit message.


> +static struct tcp_congestion_ops agilesdtcp __read_mostly = {
> +	.init		= agilesdtcp_init,
> +	.ssthresh	= agilesdtcp_recalc_ssthresh, 	//REQUIRED
> +	.cong_avoid	= agilesdtcp_cong_avoid, 	//REQUIRED
> +	.set_state	= agilesdtcp_state,
> +	.undo_cwnd	= agilesdtcp_undo_cwnd,
> +	.pkts_acked	= agilesdtcp_acked,
> +	.owner		= THIS_MODULE,
> +	.name		= "agilesd", 			//REQUIRED
> +	//.min_cwnd	= agilesdtcp_min_cwnd, 		//NOT REQUIRED
> +};

Your code must match kernel coding style. See Documentation for more
info and use the checkpatch.pl checking script.
