From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Tue, 03 Oct 2017 15:42:57 -0700
Message-ID: <1507070577.8061.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: Richard Sailer <richard_siegfried@systemli.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37781 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750865AbdJCWnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:43:00 -0400
Received: by mail-pg0-f67.google.com with SMTP id o1so10017932pga.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 15:42:59 -0700 (PDT)
In-Reply-To: <20171003222213.7996-1-richard_siegfried@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-04 at 00:22 +0200, Richard Sailer wrote:
> net/ipv4 currently contains around 100 source files containing the
> IP implementation and lots of other functionality (UDP, TCP, xfrm, etc.)
> 
> # 1/3
> To make the networking source tree more self documenting and well 
> structured 1/3 moves the 30 shared TCP source files to a own 
> subdirectory of net/ipv4/.
> 
> # 2/3 
> A huge part of the TCP code is congestion control algorithms.
> With the same goal as above, this moves the cc algos to a own
> subdirectory of net/ipv4/tcp/
> 
> # 3/3
> Implementation of a suggestion of valdis, to have a new directory
> net/ipv4v6_shared that contains all the code shared between
> IPv4 and IPv6. This creates net/ipv4v6_shared and moves the 
> net/ipv4/tcp directory of shared TCP code there.
> 
> While every commit depends on its previous commits, it is
> also possible and sensible to only apply (1) or (1,2) , depending
> on how conservative one wants to decide regarding directory
> structure changes.
> 
> [PATCH net-next 1/3] net/ipv4: Move shared tcp code to own subdirectory
> [PATCH net-next 2/3] tcp: Move cc algorithms to own subdirectory
> [PATCH net-next 3/3] Move shared tcp code to net/ipv4v6shared


NACK for the whole series.

Simple reason :

This is going to be a maintenance nightmare, for people dealing with TCP
stack every day.
