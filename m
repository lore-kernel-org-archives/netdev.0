From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 06 Dec 2012 16:38:23 -0500 (EST)
Message-ID: <20121206.163823.1350507905288784162.davem@davemloft.net>
References: <1354796760.20888.217.camel@localhost>
	<20121206123248.GA24493@breakpoint.cc>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70E2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jbrouer@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, tgraf@suug.ch, paulmck@linux.vnet.ibm.com,
	amwang@redhat.com, herbert@gondor.hengli.com.au
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423362Ab2LFViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 16:38:25 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70E2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 6 Dec 2012 13:29:13 -0000

> NFS/UDP is about the only thing that generates very large
> IP datagrams - and no one in their right mind runs that
> over non-local links.

There are people with real applications that use UDP with
large IP datagrams.  As unfortunate as it is, this is the
reality we have to deal with.
