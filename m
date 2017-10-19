From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/2] ipv6: start fib6 gc on RTF_CACHE dst
 creation
Date: Thu, 19 Oct 2017 11:45:21 +0300
Message-ID: <97ece170-439f-18aa-0d2e-d23ccd1d9479@cogentembedded.com>
References: <cover.1508358132.git.pabeni@redhat.com>
 <22a7dd612b11e30164ad489fb1446b9f6e2de9e6.1508358132.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:53506 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752340AbdJSIpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 04:45:25 -0400
Received: by mail-lf0-f54.google.com with SMTP id l23so8701449lfk.10
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 01:45:24 -0700 (PDT)
In-Reply-To: <22a7dd612b11e30164ad489fb1446b9f6e2de9e6.1508358132.git.pabeni@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/18/2017 11:23 PM, Paolo Abeni wrote:

> After the commit Fixes: 2b760fcf5cfb ("ipv6: hook up exception

    Fixes: belongs in the tag section. :-)

> table to store dst cache"), the fib6 gc is not started after
> the creation of a RTF_CACHE via a redirect or pmtu update, since
> fib6_add() isn't invoked anymore for such dsts.
> 
> We need the fib6 gc to run periodically to clean the RTF_CACHE,
> or the dst will stay there forever.
> 
> Fix it by explicitly calling fib6_force_start_gc() on successful
> exception creation. gc_args->more accounting will ensure that
> the gc timer will run for whatever time needed to properly
> clean the table.
> 
> Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Wei Wang <weiwan@google.com>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
[...]

MBR, Sergei
