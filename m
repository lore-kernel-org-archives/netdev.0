From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: Correct off-by-one errors in bounds checks
Date: Fri, 27 Dec 2013 13:08:47 -0500 (EST)
Message-ID: <20131227.130847.840672527417825080.davem@davemloft.net>
References: <1387512644-31759-1-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org
To: david@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab3L0SIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:08:49 -0500
In-Reply-To: <1387512644-31759-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <david@gibson.dropbear.id.au>
Date: Fri, 20 Dec 2013 15:10:44 +1100

> netxen_process_lro() contains two bounds checks.  One for the ring number
> against the number of rings, and one for the Rx buffer ID against the
> array of receive buffers.
> 
> Both of these have off-by-one errors, using > instead of >=. The correct
> versions are used in netxen_process_rcv(), they're just wrong in
> netxen_process_lro().
> 
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Looks good, applied, thanks David.
