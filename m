From: Richard Sailer <richard_siegfried@systemli.org>
Subject: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Wed,  4 Oct 2017 00:22:10 +0200
Message-ID: <20171003222213.7996-1-richard_siegfried@systemli.org>
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:59434 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdJCW3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:29:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4 currently contains around 100 source files containing the
IP implementation and lots of other functionality (UDP, TCP, xfrm, etc.)

# 1/3
To make the networking source tree more self documenting and well 
structured 1/3 moves the 30 shared TCP source files to a own 
subdirectory of net/ipv4/.

# 2/3 
A huge part of the TCP code is congestion control algorithms.
With the same goal as above, this moves the cc algos to a own
subdirectory of net/ipv4/tcp/

# 3/3
Implementation of a suggestion of valdis, to have a new directory
net/ipv4v6_shared that contains all the code shared between
IPv4 and IPv6. This creates net/ipv4v6_shared and moves the 
net/ipv4/tcp directory of shared TCP code there.

While every commit depends on its previous commits, it is
also possible and sensible to only apply (1) or (1,2) , depending
on how conservative one wants to decide regarding directory
structure changes.

[PATCH net-next 1/3] net/ipv4: Move shared tcp code to own subdirectory
[PATCH net-next 2/3] tcp: Move cc algorithms to own subdirectory
[PATCH net-next 3/3] Move shared tcp code to net/ipv4v6shared
