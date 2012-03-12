From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 19:55:42 -0700 (PDT)
Message-ID: <20120311.195542.1995263719633128071.davem@davemloft.net>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2CLCzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 22:55:45 -0400
In-Reply-To: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 11 Mar 2012 19:48:46 -0700 (PDT)

> This patch allows a server application to get the TCP SYN packets for
> its passive connections.  This is useful if the server is doing
> fingerprinting of clients based on SYN packet contents.
> 
> Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.  The
> first is used on a listener socket to enable saving the SYN packets
> for child connections.  The latter is used to retrieve the SYN for
> and accepted connection.  TCP_SAVED_SYN is read once, it frees the
> saved SYN packet.
> 
> The data returned TCP_SAVED_SYN is the IP header (v4 or v6) through
> the TCP header.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

I dunno, bloating up the socket and the mini-req structure by 8+ bytes
for what's essentially a very fringe feature?
