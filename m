From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netfront: always set num queues if
 possible
Date: Sun, 20 Sep 2015 21:39:33 -0700 (PDT)
Message-ID: <20150920.213933.179049285151967397.davem@davemloft.net>
References: <1442266096.3494.15.camel@gmail.com>
	<55F7FA2D.5040701@citrix.com>
	<1442435305.3494.21.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880AbbIUEje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 00:39:34 -0400
In-Reply-To: <1442435305.3494.21.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charles (Chas) Williams" <3chas3@gmail.com>
Date: Wed, 16 Sep 2015 16:28:25 -0400

> If netfront connects with two (or more) queues and then reconnects with
> only one queue it fails to delete or rewrite the multi-queue-num-queues
> key and netback will try to use the wrong number of queues.
> 
> Always write the num-queues field if the backend has multi-queue support.
> 
> Signed-off-by: Chas Williams <3chas3@gmail.com>

Applied, thanks Chas.
