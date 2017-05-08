From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: ipv4: add code comment for clarification
Date: Mon, 08 May 2017 10:44:27 -0500
Message-ID: <20170508104427.Horde.jrko8gSbk6ftIkwXE4ywgc5@gator4166.hostgator.com>
References: <20170504142432.Horde.g9y26Ryxbtg1EIl_cnsdbbw@gator4166.hostgator.com>
 <20170504194415.GA29391@embeddedgus>
 <20170508.113637.783558334411383400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([192.185.193.11]:33303 "EHLO
        gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751191AbdEHQEl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 12:04:41 -0400
Received: from cm6.websitewelcome.com (cm6.websitewelcome.com [108.167.139.19])
        by gateway30.websitewelcome.com (Postfix) with ESMTP id 4D4BB588D6
        for <netdev@vger.kernel.org>; Mon,  8 May 2017 10:44:29 -0500 (CDT)
In-Reply-To: <20170508.113637.783558334411383400.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Quoting David Miller <davem@davemloft.net>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 4 May 2017 14:44:16 -0500
>
>> @@ -389,6 +389,12 @@ static int sk_diag_fill(struct sock *sk,  
>> struct sk_buff *skb,
>>  				  nlmsg_flags, unlh, net_admin);
>>  }
>>
>> +/*
>> + * Ignore the position of the arguments req->id.idiag_dport and
>> + * req->id.idiag_sport in both calls to inet_lookup() and inet6_lookup()
>> + * functions, once this is a locked in behavior exposed to user space.
>> + * Changing this will break things for people.
>> + */
>
> This is implicit for every interface exposed to userspace.
>
> Therefore, saying it here and there in various comments provides
> questionable value.
>
> And in fact I think these arguments are probably in the correct order.
>
> I'm definitely not applying a patch like this, sorry.

I get it, thanks for clarifying.
