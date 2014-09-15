From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: curent state of GSO over IPv6 tunnel
Date: Mon, 15 Sep 2014 03:14:14 -0700
Message-ID: <1410776054.7106.141.camel@edumazet-glaptop2.roam.corp.google.com>
References: <B5657A6538887040AD3A81F1008BEC63B365F6@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45902 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbaIOKOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:14:19 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so6063721pad.20
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:14:15 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B365F6@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-15 at 08:55 +0000, Yuval Mintz wrote:
> Hi,
> 
> Tried running simple scenarios using ipv6/ipv6 via gre-tunnel [ip6_gre].
> 
> When I've tried sniffing Tx traffic [tcpdump] I've noticed there were
> no aggregations being set, i.e., only MTU-sized packets reached NIC.
> 
> Looking at output of `ethtool -k', I can see `tx_gre_segmentation' is on.
> 
> What's the current state of the feature? Is it feasible and I'm missing
> some configuration, or is it yet an unsupported feature?

As far as I know, only bnx2x driver currently supports NETIF_F_GSO_GRE
