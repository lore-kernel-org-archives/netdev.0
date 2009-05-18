From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Sun, 17 May 2009 20:39:53 -0700 (PDT)
Message-ID: <20090517.203953.162821389.davem@davemloft.net>
References: <m17i0pwg0w.fsf@fess.ebiederm.org>
	<20090510.010821.00122250.davem@davemloft.net>
	<4A08640D.7020100@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59841
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754410AbZERDjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:39:55 -0400
In-Reply-To: <4A08640D.7020100@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Mon, 11 May 2009 11:44:45 -0600

> If a DHCP server is delayed, it's possible for the client to receive the 
> DHCPOFFER after it has already sent out a new DHCPDISCOVER message from 
> a second interface.  The client then sends out a DHCPREQUEST from the 
> second interface, but the server doesn't recognize the device and 
> rejects the request.
> 
> This patch simply tracks the current device being configured and throws 
> away the OFFER if it is not intended for the current device.  A more 
> sophisticated approach would be to put the OFFER information into the 
> struct ic_device rather than storing it globally.
> 
> Signed-off-by: Chris Friesen <cfriesen@nortel.com>

Applied, thanks Chris.
