From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: 6LoWPAN basic support
Date: Tue, 16 Aug 2011 22:38:08 +0400
Message-ID: <CAJmB2rDEyzaAb4zsuhbr_XY=4BFzHv9zwYtA5BHQzO4R8tuZ2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38590 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab1HPSiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 14:38:09 -0400
Received: by gxk21 with SMTP id 21so158221gxk.19
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 11:38:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

the following patch adds basic support for 6LoWPAN techology.
This is an implementation of ipv6 header compression according
RFC4944 which allows transmit data over IEEE802.15.4 networks
using IPv6 stack.

Currently it's only basic support which works with packet size less
than 128 bytes. In this patch 6LoWPAN is implemented as midle-layer
between IEEE802.15.4 and IPv6 stacks.

Features supported:
1. TCP header compression;
2. Neighbour discovery.

The following features are going to be implemented:
1. Fragmentation (the MTU of IEEE802.15.4 is 128 bytes);
2. UDP and NextHeader compression;
3. Context-based compression.
