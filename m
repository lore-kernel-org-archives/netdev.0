From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Tue, 07 Oct 2014 13:01:27 -0400 (EDT)
Message-ID: <20141007.130127.2186178418361529001.davem@davemloft.net>
References: <CAADnVQJf8jtRr3xBdSOt_X188Xkkg0EnxVd+gh6ruTMjc9jOHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danny.zhou@intel.com, willemb@google.com, john.fastabend@gmail.com,
	dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454AbaJGRBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:01:31 -0400
In-Reply-To: <CAADnVQJf8jtRr3xBdSOt_X188Xkkg0EnxVd+gh6ruTMjc9jOHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 7 Oct 2014 09:33:04 -0700

> I guess that's great for DPDK users, but I don't think it's good for
> linux.

Any use of a piece of hardware is fine with me, personally, as long
as adequate protections are in place.

If it's just a descriptor ring in software and a doorbell to trigger
a refetch of the head and tail pointers, with appropriate protection
and control of the memory attached to the ring, I don't see how I
could object to such a facility.
