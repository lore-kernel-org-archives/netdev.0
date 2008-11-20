From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix tiny output corruption of /proc/net/snmp6
Date: Thu, 20 Nov 2008 04:20:19 -0800 (PST)
Message-ID: <20081120.042019.47910413.davem@davemloft.net>
References: <20081120090807.GD1927@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754481AbYKTMUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:20:19 -0500
In-Reply-To: <20081120090807.GD1927@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 20 Nov 2008 12:08:07 +0300

> Because "name" is static, it can be occasionally be filled with
> somewhat garbage if two processes read /proc/net/snmp6.
> 
> Also, remove useless casts and "-1" -- snprintf() correctly terminates it's
> output.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
