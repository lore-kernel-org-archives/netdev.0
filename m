From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 20:56:11 -0700 (PDT)
Message-ID: <20170915.205611.1098466403199509032.davem@davemloft.net>
References: <20170915222218.6613-1-rosenp@gmail.com>
        <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
        <1505520210.29839.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, rosenp@gmail.com, netdev@vger.kernel.org,
        zajec5@gmail.com, nbd@nbd.name
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdIPD4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 23:56:21 -0400
In-Reply-To: <1505520210.29839.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Sep 2017 17:03:30 -0700

> On Fri, 2017-09-15 at 15:54 -0700, Florian Fainelli wrote:
>> On September 15, 2017 3:22:18 PM PDT, Rosen Penev <rosenp@gmail.com>
>> wrote:
>> >On a linksys E1200v1 (actually a crossflashed E1000v2), the
>> offloading
>> >features give no measurable benefit to speed or latency. Furthermore,
>> >disabling GRO actually improves iperf performance by a whoppimg
>> 3mbps.
>> 
>> Do you have a way to generate gigabit tests and see what results you
>> are getting? We probably are not going to see a 30% improvement just
>> by extrapolation.
>> 
> +1
> 
> It seems silly to remove NETIF_F_SG | NETIF_F_IP_CSUM |
> NETIF_F_IPV6_CSUM from dev->features, yet leave the dead-code in the
> driver to handle these features.
> 
> And of course GRO was not removed, meaning the bench results were non
> conclusive.

My sentiments exactly, I think this is a completely unwise change.
