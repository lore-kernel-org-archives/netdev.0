From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Wed, 11 Nov 2009 09:22:41 -0500
Message-ID: <a30adfc1658e1d5f2f35fee1bb89b364@coraid.com>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: shemminger@vyatta.com, ecashin@coraid.com, davem@davemloft.net,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.ata-over-ethernet.org ([12.51.113.4]:38241 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753188AbZKKOWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 09:22:50 -0500
In-Reply-To: <20091110150617.0e6920f0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue Nov 10 18:06:41 EST 2009, shemminger@vyatta.com wrote:
...
> Hmm, looks like AOE actually is not ref counting the network device.
> So my patch is incorrect. 
> 
> As it stands (before my patch), it is UNSAFE. It can decide to queue
> packets to a device that is removed out from underneath it causing
> reference to freed memory.

Yes, that's right.  I will look at the patch you sent in the follow
up.  Thanks.

-- 
  Ed
