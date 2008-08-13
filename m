From: David Miller <davem@davemloft.net>
Subject: Re: Question on how to select specific tx queues for tx multiqueue
 in 2.6.27
Date: Wed, 13 Aug 2008 15:11:02 -0700 (PDT)
Message-ID: <20080813.151102.203389904.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F13E0F8FF@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751654AbYHMWLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:11:01 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F13E0F8FF@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Wed, 13 Aug 2008 14:35:55 -0700

> At this point it appears 2.6.27 broke something that used to work in
> 2.6.2[3456], what should we do at this point to get multiqueue tx
> back to having the same user space configuration that worked before?

You can write a qdisc that does these things if you wish.
I'm happy to accept patches.  The previous stuff was totally
a joke so there is no reason that I have to spend the time to
replace it since I make the TX multiqueue stuff actually useful.

On the front end we will have a simply ethtool interface that can
select from a small fixed set of hashing algorithms.  Two that will
definitely be there is the current hash function and one based upon
smp_processor_id().
