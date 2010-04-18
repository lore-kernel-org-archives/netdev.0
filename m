From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: remove time limit in
 process_backlog()
Date: Sun, 18 Apr 2010 02:36:04 -0700 (PDT)
Message-ID: <20100418.023604.138694097.davem@davemloft.net>
References: <1271489739.16881.4586.camel@edumazet-laptop>
	<z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
	<1271513822.16881.4734.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755938Ab0DRJgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 05:36:00 -0400
In-Reply-To: <1271513822.16881.4734.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Apr 2010 16:17:02 +0200

> - There is no point to enforce a time limit in process_backlog(), since
> other napi instances dont follow same rule. We can exit after only one
> packet processed...
> The normal quota of 64 packets per napi instance should be the norm, and
> net_rx_action() already has its own time limit.
> Note : /proc/net/core/dev_weight can be used to tune this 64 default
> value.
> 
> - Use DEFINE_PER_CPU_ALIGNED for softnet_data definition.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yep, doing this time limit at two levels is pointless.

Applied, thanks Eric!
