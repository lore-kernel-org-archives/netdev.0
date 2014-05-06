From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] ipv4: remove inet_addr_hash_lock in devinet.c
Date: Mon, 5 May 2014 21:33:56 -0700
Message-ID: <CAM_iQpUkEP6O4xcjRNDVwrQ2dWObP0aC2oNucpOgE_oju+DR-Q@mail.gmail.com>
References: <1399315610-28771-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140505.163524.1995679741348650063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:34183 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaEFEd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 00:33:57 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so2243993oag.32
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 21:33:57 -0700 (PDT)
In-Reply-To: <20140505.163524.1995679741348650063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2014 at 1:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon,  5 May 2014 11:46:50 -0700
>
>> All the callers hold RTNL lock, so there is no need to use inet_addr_hash_lock
>> to protect the hash list.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> If you are going to do this, please add ASSERT_RTNL() to these two locations
> at the same time.
>

OK, makes sense. I will send v2.
