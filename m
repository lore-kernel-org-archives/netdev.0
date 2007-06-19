From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Tue, 19 Jun 2007 23:14:21 +0200
Message-ID: <4678472D.5050907@trash.net>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain> <20070619090027.3312f2cf@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33915 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424AbXFSVOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 17:14:49 -0400
In-Reply-To: <20070619090027.3312f2cf@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Looks good. I have some changes to allow devices with multiple MAC addresses
> (never finished).  This device could use that.


How would the driver do that? I was thinking about using dev_add_mc,
but wasn't sure if that would work with all drivers for non-multicast
addresses.

