From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Tue, 19 Jun 2007 15:29:28 -0700
Message-ID: <20070619152928.38738411@localhost.localdomain>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
	<20070619090027.3312f2cf@localhost.localdomain>
	<4678472D.5050907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53868 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757208AbXFSWaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 18:30:23 -0400
In-Reply-To: <4678472D.5050907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jun 2007 23:14:21 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Looks good. I have some changes to allow devices with multiple MAC addresses
> > (never finished).  This device could use that.
> 
> 
> How would the driver do that? I was thinking about using dev_add_mc,
> but wasn't sure if that would work with all drivers for non-multicast
> addresses.
> 

Basically, add a new dev_add_addr hook to netdevice.
Drivers that can do it, would add the hook. If driver didn't have hook,
then core would put device into promiscuous.  Most devices with multicast
allow non-multicast addresses, so it could be a simple extension.
Rather than doing it for all devices, wanted to go in one by one and test.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
