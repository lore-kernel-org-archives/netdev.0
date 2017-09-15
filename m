From: rosenp@gmail.com
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 16:55:28 -0700
Message-ID: <1505519728.8507.0.camel@gmail.com>
References: <20170915222218.6613-1-rosenp@gmail.com>
         <20170915.161403.2131524326226213839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, nbd@nbd.name
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:48726 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdIOXzb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 19:55:31 -0400
Received: by mail-pg0-f51.google.com with SMTP id v66so2333454pgb.5
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 16:55:31 -0700 (PDT)
In-Reply-To: <20170915.161403.2131524326226213839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

you're absolutely correct. will send an updated version shortly.

On Fri, 2017-09-15 at 16:14 -0700, David Miller wrote:
> From: Rosen Penev <rosenp@gmail.com>
> Date: Fri, 15 Sep 2017 15:22:18 -0700
> 
> > On a linksys E1200v1 (actually a crossflashed E1000v2), the
> offloading features give no measurable benefit to speed or latency.
> Furthermore, disabling GRO actually improves iperf performance by a
> whoppimg 3mbps. Results:
>  ...
> > -     net_dev->features = NETIF_F_SG | NETIF_F_IP_CSUM |
> NETIF_F_IPV6_CSUM;
> > +     net_dev->features &= NETIF_F_GRO;
> >       net_dev->hw_features = net_dev->features;
> 
> This doesn't disable GRO.
