From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Namespaceify tcp_tw_recycle and
 tcp_max_tw_buckets knob
Date: Thu, 29 Dec 2016 11:39:18 -0500 (EST)
Message-ID: <20161229.113918.565955579696972850.davem@davemloft.net>
References: <1482918753-1235-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kernel@kyup.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482918753-1235-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 28 Dec 2016 17:52:32 +0800

> Different namespace application might require fast recycling
> TIME-WAIT sockets independently of the host.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied, but:

> @@ -111,6 +121,7 @@ struct netns_ipv4 {
>  	int sysctl_tcp_fin_timeout;
>  	unsigned int sysctl_tcp_notsent_lowat;
>  	int sysctl_tcp_tw_reuse;
> +	struct inet_timewait_death_row tcp_death_row; 
                                                     ^^

Trailing whitespace I had to fix up.
