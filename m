From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] gue: Changes to ip_tunnel to support
 Generic UDP Encapsulation
Date: Sun, 20 Jul 2014 21:39:06 -0700 (PDT)
Message-ID: <20140720.213906.2075766994230053164.davem@davemloft.net>
References: <alpine.DEB.2.02.1407162055520.29792@tomh.mtv.corp.google.com>
	<20140717.145345.1627726281054820171.davem@davemloft.net>
	<CA+mtBx9+i35xJjDmupJY7UA5quW=Cfmq2aQ6r3j7iJ0M8WmtHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbaGUEjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 00:39:08 -0400
In-Reply-To: <CA+mtBx9+i35xJjDmupJY7UA5quW=Cfmq2aQ6r3j7iJ0M8WmtHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 20 Jul 2014 20:31:18 -0700

> Changing to the IP tunnel code to use netlink instead of ioctls looks
> like a pretty major undertaking.

It already does via ->newlink()
