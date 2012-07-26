From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] pch_gbe: fix transmit watchdog timeout
Date: Thu, 26 Jul 2012 14:30:53 -0700 (PDT)
Message-ID: <20120726.143053.1132172317182147577.davem@davemloft.net>
References: <20120726155907.GB10287@telcoserv5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andycress@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2GZVax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:30:53 -0400
In-Reply-To: <20120726155907.GB10287@telcoserv5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Cress <andycress@gmail.com>
Date: Thu, 26 Jul 2012 11:59:07 -0400

> 
> An extended ping test with 6 vlans resulted in a driver oops with a
> netdev transmit timeout.
> Fix WATCHDOG_TIMEOUT to be more like e1000e at 5 * HZ, to avoid 
> unnecessary transmit timeouts.
> 
> Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

Applied.
