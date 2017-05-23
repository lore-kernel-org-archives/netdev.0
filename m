From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/5] net: flow_dissector: add support for
 dissection of tcp flags
Date: Tue, 23 May 2017 17:22:58 +0200
Message-ID: <20170523152258.GI1829@nanopsycho>
References: <20170523143110.5006-1-jiri@resnulli.us>
 <20170523143110.5006-3-jiri@resnulli.us>
 <29df9132-b171-58fc-e943-9d6654867c57@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, simon.horman@netronome.com,
        mlxsw@mellanox.com, idosch@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32905 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964988AbdEWPXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:23:01 -0400
Received: by mail-wm0-f68.google.com with SMTP id b84so24380325wmh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:23:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <29df9132-b171-58fc-e943-9d6654867c57@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 05:18:33PM CEST, ogerlitz@mellanox.com wrote:
>On 5/23/2017 5:31 PM, Jiri Pirko wrote:
>> @@ -683,6 +708,12 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>>   	case IPPROTO_MPLS:
>>   		proto = htons(ETH_P_MPLS_UC);
>>   		goto mpls;
>> +	case IPPROTO_TCP:
>> +		__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
>> +				       data, nhoff, hlen);
>> +		/* Regardless of the return value, continue to process TCP
>> +		 * ports dissection below.
>> +		 */
>
>the comment here is a bit misleading, since __skb_flow_dissect_tcp is void


Fixed for v2

>
>other-wise
>
>Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

Thanks
