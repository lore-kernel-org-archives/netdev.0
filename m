From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Wed, 10 Dec 2008 15:21:49 -0800 (PST)
Message-ID: <20081210.152149.256482591.davem@davemloft.net>
References: <1228899142.7542.31.camel@bzorp.balabit>
	<20081210.005728.41175879.davem@davemloft.net>
	<1228904130.7542.57.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58280
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755659AbYLJXVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 18:21:48 -0500
In-Reply-To: <1228904130.7542.57.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Wed, 10 Dec 2008 11:15:30 +0100

> Updated patch below. The SYN validation could still be improved to match
> the one in tcp_timewait_state_process(), the current one is very
> simplistic, but the approach is already visible.
> 
> [TPROXY] kick out TIME_WAIT sockets in case a new connection comes in with the same tuple

This looks fine to me.  Let me know when you have a final version
for me to apply to net-next-2.6
