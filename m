From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 17:18:15 -0700
Message-ID: <1505521095.29839.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170915222218.6613-1-rosenp@gmail.com>
         <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
         <1505520210.29839.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505520638.8507.2.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        zajec5@gmail.com, nbd@nbd.name
To: rosenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:53636 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdIPASR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 20:18:17 -0400
Received: by mail-pf0-f170.google.com with SMTP id x78so2207353pff.10
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 17:18:17 -0700 (PDT)
In-Reply-To: <1505520638.8507.2.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-15 at 17:10 -0700, rosenp@gmail.com wrote:
> Ok fair enough. Will only disable GRO in the driver.

Well, do not even try.

NETIF_F_SOFT_FEATURES is set by core networking stack in
register_netdevice(), ( commit 212b573f5552c60265da721ff9ce32e3462a2cdd
)

Absolutely no driver disables GRO (excepts the ones playing with LRO)
