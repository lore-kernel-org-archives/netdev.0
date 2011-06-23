From: David Miller <davem@davemloft.net>
Subject: Re: unintended ipv4 broadcast policy change
Date: Thu, 23 Jun 2011 14:08:21 -0700 (PDT)
Message-ID: <20110623.140821.674961342350404546.davem@davemloft.net>
References: <20110623081614.213a432f@nehalam.ftrdhcpuser.net>
	<20110623.134504.1261579649197526589.davem@davemloft.net>
	<20110623170137.69054c83@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab1FWVI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 17:08:26 -0400
In-Reply-To: <20110623170137.69054c83@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 23 Jun 2011 17:01:37 -0400

> Standard Debian stable (Squeeze) installation.
> $ dpkg -S /sbin/dhclient
> isc-dhcp-client: /sbin/dhclient

I bet what happens is that since it isn't reading from
the AF_PACKET socket the receive queue just fills up
and it's just in the kernel dropping packets in
packet_spkt_rcv().
