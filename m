From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: fix initial packet flood if !STP
Date: Sun, 17 May 2009 21:13:48 -0700 (PDT)
Message-ID: <20090517.211348.115670295.davem@davemloft.net>
References: <20090515091013.44b624d7@nehalam>
	<20090515091158.55090cd0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbZERENu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:13:50 -0400
In-Reply-To: <20090515091158.55090cd0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 May 2009 09:11:58 -0700

> If bridge is configured with no STP and forwarding delay of 0 (which
> is typical for virtualization) then when link starts it will flood all
> packets for the first 20 seconds. 
> 
> This bug was introduced by a combination of earlier changes:
>   * forwarding database uses hold time of zero to indicate 
>     user wants to always flood packets
>   * optimzation of the case of forwarding delay of 0 avoids the initial
>     timer tick
> 
> The fix is to just skip all the topology change detection code if
> kernel STP is not being used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Also applied, thanks Stephen.

To avoid confusion, I did apply these to net-2.6 since they
are fixes.

Thanks!
