From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Wed, 28 Nov 2007 13:27:11 +0100
Message-ID: <18253.24223.970902.546253@robur.slu.se>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Auke Kok <sofar@foo-projects.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:38092 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbXK1M7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 07:59:44 -0500
In-Reply-To: <20071127140904.20c4cba8@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stephen Hemminger writes:

 > It is considered a driver bug in 2.6.24 to call netif_rx_complete (clear NAPI_STATE_SCHED)
 > and do a full quota. That bug already had to be fixed in other drivers,
 > look like e1000 has same problem.

 From what I see the problem is not related to ->poll. But it's a variant of the same theme
 here it's napi_disable in  XXXX_down via ifconfig down that clears NAPI_STATE_SCHED while
 driver delivers a full quota.
 
 Cheers
						--ro
