From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 4/7] ipv6 addrconf: add new sysctl
 'router_solicitation_max_interval'
Date: Mon, 26 Sep 2016 15:59:43 +0200
Message-ID: <87d7f248-4d95-4253-78ae-6dd110db6330@stressinduktion.org>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com>
 <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33639 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966005AbcIZN7q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 09:59:46 -0400
In-Reply-To: <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.09.2016 13:03, Maciej Żenczykowski wrote:
> +		.procname	= "router_solicitation_max_interval",
> +		.data		= &ipv6_devconf.rtr_solicit_max_interval,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
> +	{

Is seconds granular enough?

Thanks,
Hannes
