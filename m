From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 11:22:44 -0700 (PDT)
Message-ID: <20100426.112244.260086869.davem@davemloft.net>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	<20100426.110432.104061817.davem@davemloft.net>
	<u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754095Ab0DZSWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:22:39 -0400
In-Reply-To: <u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 26 Apr 2010 11:19:05 -0700

> This also hits RSS/multiqueue. In a netperf RR test, 500 streams
> between my two 16 core AMDs:  TCP 970K tps, UDP 370K tps.  I'm
> surprised they didn't catch that in some benchmarks...

Meanwhile, these NIC vendors seem to have all the time in the world to
add iSCSI, RDMA and all the other stateful offload junk into their
firmware and silicon.

Yet they can't hash ports if the protocol is not TCP?  Beyond
baffling...
