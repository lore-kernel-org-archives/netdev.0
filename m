From: David Miller <davem@davemloft.net>
Subject: Re: using per-socket ipsec policies as user
Date: Sun, 11 Nov 2012 01:25:51 -0500 (EST)
Message-ID: <20121111.012551.425806345331543715.davem@davemloft.net>
References: <20121111062155.GB28043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab2KKGZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 01:25:55 -0500
In-Reply-To: <20121111062155.GB28043@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 11 Nov 2012 07:21:55 +0100

> in commit 6fc0b4a xfrm policy loading via setsockopt was restricted
> to CAP_NET_ADMIN. I wondered if the situation of the xfrm interface
> got better since then or what needs to be done to remove this
> restriction.

It's an intentional restrction and has a lot less to do with any
aspect of our implementation, but rather has more to do with what
operations we wish to allows non-privileged users to do or not.
