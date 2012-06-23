From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Add sysctl knob to control early socket demux
Date: Fri, 22 Jun 2012 23:00:22 -0700 (PDT)
Message-ID: <20120622.230022.1653450322283360759.davem@davemloft.net>
References: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
	<20120622.171509.1112294083000632011.davem@davemloft.net>
	<1340430326.4604.11946.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab2FWGA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 02:00:29 -0400
In-Reply-To: <1340430326.4604.11946.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Jun 2012 07:45:26 +0200

> On Fri, 2012-06-22 at 17:15 -0700, David Miller wrote:
> 
>> Furthermore, we can reduce to overhead by making a special inet
>> established hash demux that doesn't check for time-wait sockets,
>> reducing the number of probes to 1 from 2.
> 
> The timewait hash chain is on the same cache line than established one.
> And on a router, both chains are empty with a 99.999 % probability.

I understand this.

Probably a lot of the overhead has to do with the function calls
and, as I mentioned, the transport layer probing and validation.
