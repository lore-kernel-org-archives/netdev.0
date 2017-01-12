From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC net] ravb: do not use zero-length alighment DMA
 request
Date: Thu, 12 Jan 2017 19:14:52 +0300
Message-ID: <c99997c5-5c3f-d966-1ce4-e81dc7bfb42d@cogentembedded.com>
References: <1484229217-25585-1-git-send-email-horms+renesas@verge.net.au>
 <20170112.102102.2249793963798495642.davem@davemloft.net>
 <20170112154647.GA2329@verge.net.au>
 <20170112.110402.1123747824643306383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: magnus.damm@gmail.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>, horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:32969 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdALQO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:14:57 -0500
Received: by mail-lf0-f45.google.com with SMTP id k86so16526848lfi.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:14:56 -0800 (PST)
In-Reply-To: <20170112.110402.1123747824643306383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 07:04 PM, David Miller wrote:

>> What I now see is that a few lines further up there is:
>>
>> 	 if (skb_put_padto(skb, ETH_ZLEN))
>> 		goto drop;
>>
>> 	where ETH_ZLEN is 60.
>>
>> So I don't think we need to worry about skb->len being less than 60 and
>> this patch can be simplified to:
>>
>> 	if (len == 0)
>> 		len = 4;
>
> I'd say this might deserve a comment...

    Sure. And the one better than the original "quick fix"... :-)

MBR, Sergei
