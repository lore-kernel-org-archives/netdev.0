From: "Tommy S. Christensen" <tsc@gurgi.dk>
Subject: Re: [PATCH net-next 1/8] bridge: bridge port parameters over netlink
Date: Tue, 30 Oct 2012 19:48:53 +0100
Message-ID: <50902115.3090005@gurgi.dk>
References: <20121030005731.843020405@vyatta.com> <20121030005835.289407930@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csmtp2.one.com ([91.198.169.22]:59298 "EHLO csmtp2.one.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965610Ab2J3Ss4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 14:48:56 -0400
In-Reply-To: <20121030005835.289407930@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2012 01:57 AM, Stephen Hemminger wrote:
>
> -/*
> - * Change state of port (ie from forwarding to blocking etc)
> +static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
> +	[IFLA_BRPORT_STATE]	= { .type = NLA_U8 },
> +	[IFLA_BRPORT_COST]	= { .type = NLA_U16 },
> +	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U32 },
> +	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
> +};
> +

Hey Stephen

It seems you've swapped the sizes of COST and PRIORITY in this part.

-Tommy
