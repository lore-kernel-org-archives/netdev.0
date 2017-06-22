From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] udp: ipv6: reset daddr and dport in sk if connect() fails
Date: Thu, 22 Jun 2017 10:49:24 -0700
Message-ID: <CAEA6p_Ba+b3s-H-kM1SCu5f2T413EF0Z8sOP-tfbDDJm3YotVw@mail.gmail.com>
References: <20170621213631.145600-1-tracywwnj@gmail.com> <20170622.132500.2137901400094983652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?B?546L6JSa?= <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        subashab@codeaurora.org,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:35152 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdFVRtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:49:25 -0400
Received: by mail-vk0-f51.google.com with SMTP id 191so2974049vko.2
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 10:49:25 -0700 (PDT)
In-Reply-To: <20170622.132500.2137901400094983652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 10:25 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <tracywwnj@gmail.com>
> Date: Wed, 21 Jun 2017 14:36:31 -0700
>
>> +             memset(&sk->sk_v6_daddr, 0 sizeof(sk->sk_v6_daddr);
>
> Tell me how that compiles.

Really sorry about that. I ported over the change manually from
another branch and made the stupid mistake...
Will send out v2 shortly.
