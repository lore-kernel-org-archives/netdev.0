From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] connector: add userspace example code into Documentation/connector/
Date: Fri, 25 Aug 2006 09:13:51 +0200
Message-ID: <44EEA32F.6030600@trash.net>
References: <20060825064956.GA20468@2ka.mipt.ru> <44EE9F53.2090303@trash.net> <20060825070527.GB1816@2ka.mipt.ru> <20060825071102.GD1816@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53139 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751090AbWHYHNy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 03:13:54 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060825071102.GD1816@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> +	l_local.nl_family = AF_NETLINK;
> +	l_local.nl_groups = 0x123; /* bitmask of requested groups */
> +	l_local.nl_pid = 0;
> +
> +	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
> +		perror("bind");
> +		close(s);
> +		return -1;
> +	}
> +
> +#if 0
> +	{
> +		int on = 0x57; /* Additional group number */
> +		setsockopt(s, SOL_NETLINK, NETLINK_ADD_MEMBERSHIP, &on, sizeof(on));
> +	}
> +#endif	
> 

That looks better, thanks.
