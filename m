From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add sendmmsg socket system call
Date: Thu, 05 May 2011 11:06:15 -0700 (PDT)
Message-ID: <20110505.110615.260077567.davem@davemloft.net>
References: <20110503162135.5e410fcf@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755494Ab1EESGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:06:48 -0400
In-Reply-To: <20110503162135.5e410fcf@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Tue, 3 May 2011 16:21:35 +1000

> This patch adds a multiple message send syscall and is the send
> version of the existing recvmmsg syscall. This is heavily
> based on the patch by Arnaldo that added recvmmsg.
> 
> I wrote a microbenchmark to test the performance gains of using
> this new syscall:
> 
> http://ozlabs.org/~anton/junkcode/sendmmsg_test.c
> 
> The test was run on a ppc64 box with a 10 Gbit network card. The
> benchmark can send both UDP and RAW ethernet packets.
...
> We see a 20% improvement in throughput on UDP send and 30%
> on raw socket send.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Great work, applied, thanks!
