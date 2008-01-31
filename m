From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6][INET]: Consolidate inet(6)_hash_connect.
Date: Thu, 31 Jan 2008 05:15:07 -0800 (PST)
Message-ID: <20080131.051507.126025471.davem@davemloft.net>
References: <47A1BFC9.2030603@openvz.org>
	<20080131130153.GP1819@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933225AbYAaNOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:14:46 -0500
In-Reply-To: <20080131130153.GP1819@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 31 Jan 2008 11:01:53 -0200

> Em Thu, Jan 31, 2008 at 03:32:09PM +0300, Pavel Emelyanov escreveu:
> > These two functions are the same except for what they call
> > to "check_established" and "hash" for a socket.
> > 
> > This saves half-a-kilo for ipv4 and ipv6.
> 
> Good stuff!
> 
> Yesterday I was perusing tcp_hash and I think we could have the hashinfo
> pointer stored perhaps in sk->sk_prot.
> 
> That way we would be able to kill tcp_hash(), inet_put_port() could
> receive just sk, etc.
> 
> What do you think?

Sounds good to me.
