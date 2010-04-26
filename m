From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 13:19:31 -0700
Message-ID: <4BD5F553.6020006@hp.com>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>	<20100426.110432.104061817.davem@davemloft.net>	<u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com> <20100426.112244.260086869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:46397 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030Ab0DZUTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 16:19:34 -0400
In-Reply-To: <20100426.112244.260086869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 26 Apr 2010 11:19:05 -0700
> 
> 
>>This also hits RSS/multiqueue. In a netperf RR test, 500 streams
>>between my two 16 core AMDs:  TCP 970K tps, UDP 370K tps.  I'm
>>surprised they didn't catch that in some benchmarks...
> 
> 
> Meanwhile, these NIC vendors seem to have all the time in the world to
> add iSCSI, RDMA and all the other stateful offload junk into their
> firmware and silicon.
> 
> Yet they can't hash ports if the protocol is not TCP?  Beyond
> baffling...

As a networking guy I can see why it seems baffling, but stepping out of myself 
and thinking like the customers with whom I've interacted over the years, it is 
not baffling at all.

By and large, customers do not do anything "substantial" with UDP.  NFS went to 
TCP mounts 99 times out of 10 many years ago, leaving DNS as about the only 
thing left*. So, customers will not be chomping at the bit for improved UDP 
scalability/performance.  They would though, be jumping up and down demanding 
iSCSI performance and by implication all that comes along for the ride.

rick jones

* And even there, one of the biggest pushes is trying to make TCP "transaction 
friendly" to deal with DNS messages becoming larger than typical MTUs.
