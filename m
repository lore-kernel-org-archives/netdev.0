From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 08:29:21 -0700
Message-ID: <1221924561.1343.121.camel@localhost.localdomain>
References: <20080919.234824.223177211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:11776 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbYITP30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 11:29:26 -0400
In-Reply-To: <20080919.234824.223177211.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-19 at 23:48 -0700, David Miller wrote:
> Jens Axboe has written some hacks for the block layer that allow
> queueing softirq work to remote cpus.  In the context of the block
> layer he used this facility to trigger the softirq block I/O
> completion on the same cpu where the I/O was submitted.
> 

> Jen's, as stated, has block layer uses for this.  I intend to use this
> for receive side flow seperation on non-multiqueue network cards.  And
> Steffen Klassert has a set of IPSEC parallelization changes that can
> very likely make use of this.

What's the benefit that you (or Jens) sees from migrating softirqs from
specific cpu's to others?

Daniel

