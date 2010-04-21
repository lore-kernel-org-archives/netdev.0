From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X25 fix dead unaccepted sockets
Date: Wed, 21 Apr 2010 16:32:02 -0700 (PDT)
Message-ID: <20100421.163202.121306838.davem@davemloft.net>
References: <1271549852.2802.37.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754848Ab0DUXb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:31:57 -0400
In-Reply-To: <1271549852.2802.37.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Sun, 18 Apr 2010 10:17:32 +1000

> 
> 1, An X25 program binds and listens
> 2, calls arrive waiting to be accepted
> 3, Program exits without accepting
> 4, Sockets time out but don't get correctly cleaned up
> 5, cat /proc/net/x25/socket shows the dead sockets with bad inode fields.
> 
> This line borrowed from AX25 sets the dying socket so the timers clean up later.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied, thank you.
