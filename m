From: David Miller <davem@davemloft.net>
Subject: Re: EACCES sending UDP to broadcast address?
Date: Thu, 09 Apr 2015 22:28:43 -0400 (EDT)
Message-ID: <20150409.222843.586154432199987277.davem@davemloft.net>
References: <552721AC.9080900@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbDJC2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 22:28:47 -0400
In-Reply-To: <552721AC.9080900@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 09 Apr 2015 18:04:44 -0700

> I'm running as root user, 4.0-rc6 + hack kernel.
> 
> User-space app is (or should be) trying to send a UDP frame
> to 255.255.255.255 destination.
> 
> I am getting EACCESS from sendmmsg.
> 
> Is this expected?  Is there something even more special than root these
> days?

You can't send to broadcast addresses without setting the
SOCK_BROADCAST socket option.

I didn't know the answer to this, it took me 10 seconds of grepping
around under net/ipv4 to figure it out.  You could have done this
too.
