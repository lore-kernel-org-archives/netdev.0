From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: Timestamp option cannot overflow with
 prespecified addresses
Date: Tue, 05 Mar 2013 23:54:11 -0500 (EST)
Message-ID: <20130305.235411.1636938131431522651.davem@davemloft.net>
References: <1362539192-9343-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251Ab3CFEyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:54:13 -0500
In-Reply-To: <1362539192-9343-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Tue, 5 Mar 2013 22:06:32 -0500

> When a router forwards a packet that contains the IPv4 timestamp option,
> if there is no space left in the option for the router to add its own
> timestamp, then the router increments the Overflow value in the option.
> 
> However, if the addresses of the routers are prespecified in the option,
> then the overflow condition cannot happen: the option is structured so
> that each prespecified router has a place to write its timestamp. Other
> routers do not add a timestamp, so there will never be a lack of space.
> 
> This fix ensures that the Overflow value in the IPv4 timestamp option is
> not incremented when the addresses of the routers are prespecified, even
> if the Pointer value is greater than the Length value.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied, thanks for fixing this.
