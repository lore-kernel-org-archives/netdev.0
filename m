From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 12:04:20 +0100
Message-ID: <1225364660.7803.61.camel@twins>
References: <49081D67.3050502@cosmosbay.com>
	 <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org>
	 <490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org>
	 <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com>
	 <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com>
	 <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com>
	 <4908C0CD.5050406@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:41425 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbYJ3LES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 07:04:18 -0400
In-Reply-To: <4908C0CD.5050406@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 21:00 +0100, Eric Dumazet wrote:

> 
> Hum... Another way of handling all those cases and avoid memory barriers
> would be to have different "NULL" pointers.
> 
> Each hash chain should have a unique "NULL" pointer (in the case of UDP, it
> can be the 128 values : [ (void*)0 .. (void *)127 ]

Why not use the bucket pointer as terminating condition?

Because all you really need is a pointer that is specific per bucket,
and not a valid element, right?


