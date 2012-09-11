From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: GRO aggregation
Date: Tue, 11 Sep 2012 21:35:32 +0200
Message-ID: <1347392132.13103.663.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 ,<1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 ,<1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongratz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53460 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757379Ab2IKTfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 15:35:37 -0400
Received: by eekc1 with SMTP id c1so722847eek.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 12:35:36 -0700 (PDT)
In-Reply-To: <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-11 at 19:24 +0000, Shlomo Pongratz wrote:

> 
> I see that in ixgbe the weight for the NAPI is 64 (netif_napi_add). So
> if packets are arriving in high rate then an the CPU is fast enough to
> collect the packets as they arrive, assuming packets continue to
> arrives while the NAPI runs. Then it should have aggregate more. So we
> will have less passes trough the stack.
> 

As I said, _if_ your cpu was loaded by other stuff, then you would see
biggest GRO packets.

GRO is not : "We want to kill latency and have big packets just because
its better"

Its more like : If load is big enough, try to aggregate TCP frames in
less skbs.
