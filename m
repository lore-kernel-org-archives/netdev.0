From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 09:56:19 -0800
Message-ID: <1295546179.28001.4.camel@Joe-Laptop>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-20 at 23:30 +0800, Po-Yu Chuang wrote:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
[]
> +	/* map io memory */
> +	priv->res = request_mem_region(res->start, res->end - res->start,
> +				       dev_name(&pdev->dev));

Off by one?

	priv->res = request_mem_region(res->start, resource_size(res),
				       dev_name(&pdev->dev));
