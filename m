From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v6 2/5] bonding: Implement port churn-machine (AD
 standard 43.4.17).
Date: Fri, 20 Feb 2015 17:33:45 -0500 (EST)
Message-ID: <20150220.173345.1387126164943361978.davem@davemloft.net>
References: <1424328619-14205-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbbBTWds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:33:48 -0500
In-Reply-To: <1424328619-14205-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 18 Feb 2015 22:50:19 -0800

> @@ -1131,6 +1137,44 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>  	}
>  }
>  
> +/* ad_churn_machine - handle port churn's state machine
> + * @port: the port we're looking at
> + *
> + */

Please don't invent new styles for the function comments, do it like it is
done in the rest of this file, for example, the very next funtion does:

>  /**
>   * ad_tx_machine - handle a port's tx state machine
>   * @port: the port we're looking at
> +	static const char *const churn_description[] =
> +		{ "monitoring",
> +		  "churned",
> +		  "none",
> +		  "unknown"
> +		};
> +	int max_size = sizeof(churn_description) / sizeof(churn_description[0]);

Please format this as:

> +	static const char *const churn_description[] = {
> +		"monitoring",
> +		"churned",
> +		"none",
> +		"unknown"
> +	};
