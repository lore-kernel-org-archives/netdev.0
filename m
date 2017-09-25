From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Mon, 25 Sep 2017 15:52:39 -0600
Message-ID: <56dd80dc-6d3e-4063-a439-f8938c65c384@gmail.com>
References: <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
 <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
 <20170925.131101.478664536826772174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:46675 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932698AbdIYVwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:52:45 -0400
Received: by mail-pf0-f172.google.com with SMTP id r68so4492174pfj.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 14:52:45 -0700 (PDT)
In-Reply-To: <20170925.131101.478664536826772174.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/25/17 2:11 PM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Mon, 25 Sep 2017 10:14:23 -0600
> 
>> I made a simple program this morning and ran it under perf.
> 
> If possible please submit this for selftests.
> 

It is more of a microbenchmark of options to flush an rbtree than a
self-test. Further, it relies on the tools/lib/rbtree.c versus
lib/rbtree.c. The tools/lib version was imported by Arnaldo in July 2015
and is a out of date, though it is good enough to show the intent w.r.t.
flushing options.
