From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 19:27:22 +0300
Message-ID: <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
 <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
 <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:51052 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751457AbdIMQ1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 12:27:25 -0400
In-Reply-To: <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-13 19:16, Eric Dumazet wrote:
> On Wed, 2017-09-13 at 18:34 +0300, Denys Fedoryshchenko wrote:
>> Well, probably i am answering my own question, removing estimator from
>> classes seems drastically improve situation.
>> It seems estimator has some issues that cause shaper to behave
>> incorrectly (throttling traffic while it should not).
>> But i guess thats a bug?
>> As i was not able to predict such bottleneck by CPU load measurements.
> 
> Well, there was a reason we disabled HTB class estimators by default ;)
> 
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=64153ce0a7b61b2a5cacb01805cbf670142339e9

As soon as disabling it solve my problem - i'm fine, hehe, but i guess 
other people who might hit this problem, should be aware how to find 
reason.
They should not be disappointed in Linux :)
Because i can't measure this bottleneck before it happens, i'm seeing on 
mpstat all cpu's are idle, and same time traffic is throttled.
