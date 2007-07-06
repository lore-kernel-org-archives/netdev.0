From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV6: Call inet6addr_chain notifiers on link down
Date: Thu, 05 Jul 2007 17:00:11 -0700 (PDT)
Message-ID: <20070705.170011.26365263.davem@davemloft.net>
References: <468A63DC.2090500@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760342AbXGEX7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:59:51 -0400
In-Reply-To: <468A63DC.2090500@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 03 Jul 2007 10:57:32 -0400

> Currently if the link is brought down via ip link or ifconfig down,
> the inet6addr_chain notifiers are not called even though all
> the addresses are removed from the interface.  This caused SCTP
> to add duplicate addresses to it's list.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Looks good, applied, thanks Vlad.
I'll push this to -stable too.
