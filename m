From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH updated] IPV6: Call inet6addr_chain notifiers on link
 down
Date: Sun, 15 Jul 2007 00:17:23 -0700 (PDT)
Message-ID: <20070715.001723.94889330.davem@davemloft.net>
References: <468E4459.6040605@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbXGOHRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 03:17:21 -0400
In-Reply-To: <468E4459.6040605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 06 Jul 2007 09:32:09 -0400

> Currently if the link is brought down via ip link or ifconfig down,
> the inet6addr_chain notifiers are not called even though all
> the addresses are removed from the interface.  This caused SCTP
> to add duplicate addresses to it's list.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks Vlad.

I'll push this to -stable too.
