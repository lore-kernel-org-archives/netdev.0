From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: ipv6: reset daddr and dport in sk if
 connect() fails
Date: Thu, 22 Jun 2017 13:54:08 -0400 (EDT)
Message-ID: <20170622.135408.293309819386939085.davem@davemloft.net>
References: <20170621213631.145600-1-tracywwnj@gmail.com>
        <20170622.132500.2137901400094983652.davem@davemloft.net>
        <CAEA6p_Ba+b3s-H-kM1SCu5f2T413EF0Z8sOP-tfbDDJm3YotVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tracywwnj@gmail.com, netdev@vger.kernel.org,
        subashab@codeaurora.org, maze@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753298AbdFVRyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:54:09 -0400
In-Reply-To: <CAEA6p_Ba+b3s-H-kM1SCu5f2T413EF0Z8sOP-tfbDDJm3YotVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Thu, 22 Jun 2017 10:49:24 -0700

> On Thu, Jun 22, 2017 at 10:25 AM, David Miller <davem@davemloft.net> wrote:
>> From: Wei Wang <tracywwnj@gmail.com>
>> Date: Wed, 21 Jun 2017 14:36:31 -0700
>>
>>> +             memset(&sk->sk_v6_daddr, 0 sizeof(sk->sk_v6_daddr);
>>
>> Tell me how that compiles.
> 
> Really sorry about that. I ported over the change manually from
> another branch and made the stupid mistake...
> Will send out v2 shortly.

Misporting the change isn't stupid.

Not build and functionally testing your change is.
