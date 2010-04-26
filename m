From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 19:27:17 -0400
Message-ID: <4BD62155.7080104@athenacr.com>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>	<20100426.110432.104061817.davem@davemloft.net>	<u2q65634d661004261119j74042496z4f1ba570251e0c44@mail.gmail.com> <20100426.112244.260086869.davem@davemloft.net> <4BD5F553.6020006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:61797 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752841Ab0D0AAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 20:00:06 -0400
In-Reply-To: <4BD5F553.6020006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> By and large, customers do not do anything "substantial" with UDP.  NFS
> went to TCP mounts 99 times out of 10 many years ago, leaving DNS as
> about the only thing left*. So, customers will not be chomping at the
> bit for improved UDP scalability/performance.  They would though, be
> jumping up and down demanding iSCSI performance and by implication all
> that comes along for the ride.

I work for a finance firm, and I've met a lot of guys who are
chomping at the bit for improved UDP performance. It's a
huge huge deal in our field. I'm nothing more than one customer
but I have a pretty negative reaction to this sentiment.

I'm also one of the people who occasionally bugs Eric Dumazet
about it :)

One saving grace for the financial multicast case: I think it's
pretty typical for the dest IP to be different for each flow
(different multicast groups). I confirmed on my multi-queue
bnx2 NIC (BCM5709) that those are spread out across the queues,
presumably the hash is similar.
