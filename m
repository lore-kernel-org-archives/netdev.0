From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Sun, 03 Nov 2013 23:20:44 -0500 (EST)
Message-ID: <20131103.232044.43459849021471837.davem@davemloft.net>
References: <527167C7.4030305@xdin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, joe@perches.com,
	jboticario@gmail.com, balferreira@googlemail.com,
	elias.molina@ehu.es
To: arvid.brodin@xdin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3KDEUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:20:46 -0500
In-Reply-To: <527167C7.4030305@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@xdin.com>
Date: Wed, 30 Oct 2013 21:10:47 +0100

> High-availability Seamless Redundancy ("HSR") provides instant failover
> redundancy for Ethernet networks. It requires a special network topology where
> all nodes are connected in a ring (each node having two physical network
> interfaces). It is suited for applications that demand high availability and
> very short reaction time.
> 
> HSR acts on the Ethernet layer, using a registered Ethernet protocol type to
> send special HSR frames in both directions over the ring. The driver creates
> virtual network interfaces that can be used just like any ordinary Linux
> network interface, for IP/TCP/UDP traffic etc. All nodes in the network ring
> must be HSR capable.
> 
> This code is a "best effort" to comply with the HSR standard as described in
> IEC 62439-3:2010 (HSRv0).
> 
> Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>

Applied, thanks.
