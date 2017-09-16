From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 17:03:30 -0700
Message-ID: <1505520210.29839.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170915222218.6613-1-rosenp@gmail.com>
         <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rosen Penev <rosenp@gmail.com>, netdev@vger.kernel.org,
        zajec5@gmail.com, nbd@nbd.name
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:47401 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdIPADb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 20:03:31 -0400
Received: by mail-pg0-f47.google.com with SMTP id d8so2343141pgt.4
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 17:03:31 -0700 (PDT)
In-Reply-To: <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-15 at 15:54 -0700, Florian Fainelli wrote:
> On September 15, 2017 3:22:18 PM PDT, Rosen Penev <rosenp@gmail.com>
> wrote:
> >On a linksys E1200v1 (actually a crossflashed E1000v2), the
> offloading
> >features give no measurable benefit to speed or latency. Furthermore,
> >disabling GRO actually improves iperf performance by a whoppimg
> 3mbps.
> 
> Do you have a way to generate gigabit tests and see what results you
> are getting? We probably are not going to see a 30% improvement just
> by extrapolation.
> 
+1

It seems silly to remove NETIF_F_SG | NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM from dev->features, yet leave the dead-code in the
driver to handle these features.

And of course GRO was not removed, meaning the bench results were non
conclusive.
