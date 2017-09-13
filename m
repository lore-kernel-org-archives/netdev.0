From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 18:56:52 +0300
Message-ID: <33c45cf6c5a52498f45132d29d86bc3d@nuclearcat.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
 <1505317903.15310.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:48602 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751258AbdIMP4z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 11:56:55 -0400
In-Reply-To: <1505317903.15310.167.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-13 18:51, Eric Dumazet wrote:
> On Wed, 2017-09-13 at 18:20 +0300, Denys Fedoryshchenko wrote:
>> Hi,
>> 
>> I noticed after increasing bandwidth over some amount HTB started to
>> throttle classes it should not throttle.
>> Also estimated rate in htb totally wrong, while byte counters is
>> correct.
>> 
>> Is there any overflow or something?
> 
> Thanks Denys for the report, I will take a look at this, since I
> probably introduced some regression.
It's definitely not something recent, this system was on older kernel 
with uptime over 200 days, and this bottleneck was present, i noticed it 
long time before.
But never tried to remove estimators (increasing burst/cburst to insane 
values saved me for a while).
