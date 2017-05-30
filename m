From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Mon, 29 May 2017 21:42:16 -0600
Message-ID: <d774d7d7-5eb2-f107-b939-fbd3a8ac97a7@gmail.com>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
 <20170529.233009.1607319852930338432.davem@davemloft.net>
 <1496115666.2618.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32859 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbdE3DmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:42:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so14884611pfe.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 20:42:23 -0700 (PDT)
In-Reply-To: <1496115666.2618.9.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/29/17 9:41 PM, Joe Perches wrote:
> On Mon, 2017-05-29 at 23:30 -0400, David Miller wrote:
>> From: yuan linyu <cugyly@163.com>
>> Date: Sat, 27 May 2017 06:00:52 +0800
>>
>>> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>>>
>>> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>> Applied, thanks.
> OK, but is it really safe though?
> 
> Could "space" (an int) ever be negative after
> subtracting "pad" and "data_len"?
> 

that function should be converted to skb_put_zero once it hits net-next.
