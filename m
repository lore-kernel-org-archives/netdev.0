From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/1] Introduction of the tc tests
Date: Tue, 20 Jun 2017 07:13:06 -0400
Message-ID: <dd121668-cb4d-edb7-1804-f4d42518cf17@mojatatu.com>
References: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
 <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com>
 <20170619.234819.333574326143678552.davem@davemloft.net>
 <20170619224027.133c3578@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, lucasb@mojatatu.com,
        netdev@vger.kernel.org, jiri@resnulli.us, mrv@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34118 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdFTLNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 07:13:09 -0400
Received: by mail-qk0-f195.google.com with SMTP id d14so10318919qkb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 04:13:09 -0700 (PDT)
In-Reply-To: <20170619224027.133c3578@plumbers-lap.home.lan>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-20 01:40 AM, Stephen Hemminger wrote:

> 
> The "Occum's razor" for deciding where tests belong should be does
> the test need to change to respond to kernel change? Don't want to have
> iproute2 tests that have if (kernel_version > ...)
> 

The suite is intended to include both forward and backward compat
tests i.e old/new iproute2/kernel. So should be possible to say
"test failed because kernel is older" without depending on specific
kernel version. Likewise for iproute2.

cheers,
jamal
