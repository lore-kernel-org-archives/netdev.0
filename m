From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Tue, 30 May 2017 18:39:35 -0600
Message-ID: <fe3573ad-90d1-6673-1e09-f6f1b47527bb@gmail.com>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
 <20170529.233009.1607319852930338432.davem@davemloft.net>
 <1496115666.2618.9.camel@perches.com>
 <d774d7d7-5eb2-f107-b939-fbd3a8ac97a7@gmail.com>
 <8729016553E3654398EA69218DA29EEF15BB29A7@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        David Ahern <dsahern@gmail.com>, Joe Perches <joe@perches.com>,
        David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36428 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdEaAji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:39:38 -0400
Received: by mail-pf0-f173.google.com with SMTP id m17so1843800pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:39:38 -0700 (PDT)
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BB29A7@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 6:29 PM, YUAN Linyu wrote:
>>> that function should be converted to skb_put_zero once it hits net-next.
>> I will check it
> I can't find skb_put_zero

I believe the decision was to put it in Johannes' tree and it will make
its way to DaveM's tree. Give some time.
