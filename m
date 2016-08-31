From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 16:29:56 -0700
Message-ID: <f131776f-7f53-c539-f283-10d6db0b6d57@hpe.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
 <20160831100854.23dad2d8@redhat.com>
 <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472650688.32433.115.camel@redhat.com>
 <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831214043.2f44cf08@redhat.com>
 <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831235116.33b1946b@redhat.com>
 <1472682450.14381.364.camel@edumazet-glaptop3.roam.corp.google.com>
 <3567b503-8b3e-5a3f-580a-f99fd28cf77e@hpe.com>
 <1472685066.14381.380.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hpe.com ([15.241.48.73]:60394 "EHLO
        g9t5009.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761178AbcHaX37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 19:29:59 -0400
In-Reply-To: <1472685066.14381.380.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2016 04:11 PM, Eric Dumazet wrote:
> On Wed, 2016-08-31 at 15:47 -0700, Rick Jones wrote:
>> With regard to drops, are both of you sure you're using the same socket
>> buffer sizes?
>
> Does it really matter ?

At least at points in the past I have seen different drop counts at the 
SO_RCVBUF based on using (sometimes much) larger sizes.  The hypothesis 
I was operating under at the time was that this dealt with those 
situations where the netserver was held-off from running for "a little 
while" from time to time.  It didn't change things for a sustained 
overload situation though.

>> In the meantime, is anything interesting happening with TCP_RR or
>> TCP_STREAM?
>
> TCP_RR is driven by the network latency, we do not drop packets in the
> socket itself.

I've been of the opinion it (single stream) is driven by path length. 
Sometimes by NIC latency.  But then I'm almost always measuring in the 
LAN rather than across the WAN.

happy benchmarking,

rick
