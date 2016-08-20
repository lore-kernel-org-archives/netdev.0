From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] openvswitch: use percpu flow stats
Date: Fri, 19 Aug 2016 22:25:01 -0700 (PDT)
Message-ID: <20160819.222501.684301846870702801.davem@davemloft.net>
References: <1471636616.29842.110.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160819.180953.970774471141286228.davem@davemloft.net>
        <1471666072.29842.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@redhat.com, dev@openvswitch.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbcHTFZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 01:25:04 -0400
In-Reply-To: <1471666072.29842.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Aug 2016 21:07:52 -0700

> Here is an example of a system I had in the past.
> 
> 8 cpus  (num_possible_cpus() returns 8)
> 
> Cpus were numbered : 0, 1, 2, 3, 8, 9, 10, 11  : (nr_cpu_ids = 12)
> 
> I am pretty sure they are still alive.
> 
> Since you want an array indexed by cpu numbers, you need to size it by
> nr_cpu_ids, otherwise array[11] will crash / access garbage.
> 
> This is why you find many nr_cpu_ids in the linux tree, not
> num_possible_cpus() to size arrays.

My bad, I misunderstood what nr_cpu_ids means.  You are absolutely right.
