From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Thu, 8 Dec 2016 07:36:47 -0800
Message-ID: <de654cac-fa3c-a4e1-a24a-27187456b8d7@hpe.com>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161208104620.5fc691b8@redhat.com>
 <1481211015.4930.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hpe.com ([15.241.140.78]:10431 "EHLO
        g4t3425.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753821AbcLHPgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:36:49 -0500
In-Reply-To: <1481211015.4930.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2016 07:30 AM, Eric Dumazet wrote:
> On Thu, 2016-12-08 at 10:46 +0100, Jesper Dangaard Brouer wrote:
>
>> Hmmm... I'm not thrilled to have such heuristics, that change memory
>> behavior when half of the queue size (sk->sk_rcvbuf) is reached.
>
> Well, copybreak drivers do that unconditionally, even under no stress at
> all, you really should complain then.

Isn't that behaviour based (in part?) on the observation/belief that it 
is fewer cycles to copy the small packet into a small buffer than to 
send the larger buffer up the stack and have to allocate and map a 
replacement?

rick jones
