From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Sun, 28 Oct 2007 19:40:29 -0700
Message-ID: <1193625629.6413.4.camel@localhost>
References: <E1IkAo9-0006xM-00@gondolin.me.apana.org.au>
	 <ygfk5p7vvq7.fsf@janus.isnogud.escape.de>
	 <1193605297.26695.121.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	acme@ghostprotocols.net, netdev@vger.kernel.org
To: Urs Thuermann <urs.thuermann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1385 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbXJ2ClP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 22:41:15 -0400
In-Reply-To: <1193605297.26695.121.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-10-28 at 14:01 -0700, Joe Perches wrote:
> probably unsigned long should be u16.

Or not.
x86 u16 performs much worse than u32 (~ 50% worse)


