From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Fix tx_restart_queue/non_eop_desc
 statistics counters
Date: Sun, 13 Dec 2009 21:07:06 -0800 (PST)
Message-ID: <20091213.210706.258124695.davem@davemloft.net>
References: <20091212075140.10952.86813.stgit@localhost.localdomain>
	<20091213.191804.226782424.davem@davemloft.net>
	<1260766625.20884.2.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, mallikarjuna.chilakala@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713AbZLNFHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 00:07:05 -0500
In-Reply-To: <1260766625.20884.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Sun, 13 Dec 2009 20:57:05 -0800

> On Sun, 2009-12-13 at 19:18 -0800, David Miller wrote:
>> I don't see how these two versions of the code can behave
>> differently unless there is very broken locking on the
>> adapter->* statistic counters.
> 
> The problem is the adapter->restart_queue is being double-counted.  If
> we accumulate from each ring's restart_queue, which are cumulative, then
> we don't want to add it to the previous update_stats() values in
> adapter->restart_queue.

Now I understand, thanks.

>> I'm not applying this without at least a better commit
>> log message.
> 
> We can fix the commit log message to better explain what the problem is.

Thanks PJ.
