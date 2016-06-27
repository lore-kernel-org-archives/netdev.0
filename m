From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vsock: make listener child lock ordering explicit
Date: Mon, 27 Jun 2016 10:45:02 -0400 (EDT)
Message-ID: <20160627.104502.1280455139010334440.davem@davemloft.net>
References: <1466695738-2393-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, imbrenda@linux.vnet.ibm.com,
	jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcF0Opb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:45:31 -0400
In-Reply-To: <1466695738-2393-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 23 Jun 2016 16:28:58 +0100

> There are several places where the listener and pending or accept queue
> child sockets are accessed at the same time.  Lockdep is unhappy that
> two locks from the same class are held.
> 
> Tell lockdep that it is safe and document the lock ordering.
> 
> Originally Claudio Imbrenda <imbrenda@linux.vnet.ibm.com> sent a similar
> patch asking whether this is safe.  I have audited the code and also
> covered the vsock_pending_work() function.
> 
> Suggested-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied, thanks.
