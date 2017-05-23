From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch net-next 2/5] net: flow_dissector: add support for
 dissection of tcp flags
Date: Tue, 23 May 2017 18:18:33 +0300
Message-ID: <29df9132-b171-58fc-e943-9d6654867c57@mellanox.com>
References: <20170523143110.5006-1-jiri@resnulli.us>
 <20170523143110.5006-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <jhs@mojatatu.com>, <xiyou.wangcong@gmail.com>,
        <simon.horman@netronome.com>, <mlxsw@mellanox.com>,
        <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0071.outbound.protection.outlook.com ([104.47.1.71]:18661
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933289AbdEWPSm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 11:18:42 -0400
In-Reply-To: <20170523143110.5006-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2017 5:31 PM, Jiri Pirko wrote:
> @@ -683,6 +708,12 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>   	case IPPROTO_MPLS:
>   		proto = htons(ETH_P_MPLS_UC);
>   		goto mpls;
> +	case IPPROTO_TCP:
> +		__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
> +				       data, nhoff, hlen);
> +		/* Regardless of the return value, continue to process TCP
> +		 * ports dissection below.
> +		 */

the comment here is a bit misleading, since __skb_flow_dissect_tcp is void

other-wise

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
