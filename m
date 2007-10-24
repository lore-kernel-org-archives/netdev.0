From: Jeff Garzik <jeff@garzik.org>
Subject: Re: on the topic of alternate MAC addresses
Date: Tue, 23 Oct 2007 22:25:05 -0400
Message-ID: <471EAD01.5030502@garzik.org>
References: <20071023.180534.59659315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33512 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbXJXCZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 22:25:07 -0400
In-Reply-To: <20071023.180534.59659315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I've been meaning to bring this up.
> 
> A lot of cards that support multiple MAC addresses
> in hardware provide pre-cooked lists of alternate
> MAC addresses.  This is either done via EEPROM,
> NVRAM, or OpenFirmware device properties.
> 
> For example, the Sun Neptune cards can provide an
> array of up to 16 alternate MAC addresses per-port.
> 
> We should provide a way to export these lists to
> userspace.
> 
> Perhaps an ethtool thing, Jeff?
> 
> Once we have this, virtualization implementations can probe for and
> use them.  Currently they have no way to discover these things so
> probably they just generate their own using some algorithm.

hmmmm.  Using ethtool isn't a big deal, but IMO you probably want more 
than just an exported list for the usage you described...  it sounds 
like some sort of reservation system should be used, to note which MAC 
addresses are [not] in use?

Then a virt client -- or anyone who wants multiple unicast addresses for 
whatever reason -- can let other clients to avoid MAC addresses 1, 7, or 
13 (random examples).

	Jeff



