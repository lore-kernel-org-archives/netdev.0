From: David Miller <davem@davemloft.net>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 09 Jan 2008 15:32:12 -0800 (PST)
Message-ID: <20080109.153212.144388472.davem@davemloft.net>
References: <20080109153656.GA16962@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757372AbYAIXcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:32:13 -0500
In-Reply-To: <20080109153656.GA16962@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@suse.de>
Date: Wed, 9 Jan 2008 16:36:56 +0100

>    If the address is a link-local address formed from an interface
>    identifier based on the hardware address, which is supposed to be
>    uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
>    operation on the interface SHOULD be disabled.  By disabling IP
>    operation, the node will then:
> 
>    -  not send any IP packets from the interface,
> 
>    -  silently drop any IP packets received on the interface, and
> 
>    -  not forward any IP packets to the interface (when acting as a
>       router or processing a packet with a Routing header).

I question any RFC mandate that shuts down IP communication on a node
because of packets received from remote systems.

If the TAHI test can trigger this, so can a compromised system on your
network and won't that be fun? :-)
