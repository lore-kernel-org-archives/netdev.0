From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Sat, 16 Sep 2017 03:25:59 +0300
Message-ID: <74955cf749601c3a7a938a6945a976f8@nuclearcat.com>
References: <20170915222218.6613-1-rosenp@gmail.com>
 <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
 <1505520210.29839.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505520638.8507.2.camel@gmail.com>
 <1505521095.29839.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: rosenp@gmail.com, Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, zajec5@gmail.com, nbd@nbd.name,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:39844 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751201AbdIPA0D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 20:26:03 -0400
In-Reply-To: <1505521095.29839.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-16 03:18, Eric Dumazet wrote:
> On Fri, 2017-09-15 at 17:10 -0700, rosenp@gmail.com wrote:
>> Ok fair enough. Will only disable GRO in the driver.
> 
> Well, do not even try.
> 
> NETIF_F_SOFT_FEATURES is set by core networking stack in
> register_netdevice(), ( commit 212b573f5552c60265da721ff9ce32e3462a2cdd
> )
> 
> Absolutely no driver disables GRO (excepts the ones playing with LRO)
I believe also iperf is definitely inconclusive test.
Except iperf there is lot of different workloads and configurations, 
that might have different results.
