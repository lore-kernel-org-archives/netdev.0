From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6: Fix CALIPSO causing GPF with datagram support
Date: Mon, 05 Jun 2017 12:00:15 -0400 (EDT)
Message-ID: <20170605.120015.1136981458406571990.davem@davemloft.net>
References: <20170605154440.2434-1-richard_c_haines@btinternet.com>
        <CAHC9VhRwzC=XTRj5gNfd11T=XzpYSrVfu-jnx9f4__duMAji1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard_c_haines@btinternet.com, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdFEQAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 12:00:23 -0400
In-Reply-To: <CAHC9VhRwzC=XTRj5gNfd11T=XzpYSrVfu-jnx9f4__duMAji1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Mon, 5 Jun 2017 11:55:34 -0400

> On Mon, Jun 5, 2017 at 11:44 AM, Richard Haines
> <richard_c_haines@btinternet.com> wrote:
>> When using CALIPSO with IPPROTO_UDP it is possible to trigger a GPF as the
>> IP header may have moved.
>>
>> Also update the payload length after adding the CALIPSO option.
>>
>> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
>> ---
>>  net/ipv6/calipso.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Acked-by: Paul Moore <paul@paul-moore.com>
> 
> Thanks Richard.  DaveM, I assume you'll be pulling this into your tree?

Sure.
