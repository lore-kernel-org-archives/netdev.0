From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/03]: ktime + nano-second clock resolution for
 packet schedulers
Date: Mon, 05 Mar 2007 18:42:26 +0100
Message-ID: <45EC5682.6000406@trash.net>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain> <20070304.162557.112625456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51901 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbXCERmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 12:42:46 -0500
In-Reply-To: <20070304.162557.112625456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Frankly, I think now that we have ktime and all of the proper generic
> infrastructure to do this stuff properly, I think we should just use
> ktime for the packet scheduler across the board and just delete all of
> that old by-hand timekeeping selection crap from pkt_sched.h

Sounds good, I'm going to remove all other clock sources.
Will resend in a couple of days after fixing a few more
problems I noticed.

