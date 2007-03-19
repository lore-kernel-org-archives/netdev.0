From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #2]
Date: Mon, 19 Mar 2007 15:29:59 +0000
Message-ID: <20070319152959.46a81e57@lxorguk.ukuu.org.uk>
References: <20070319130428.4b645207@lxorguk.ukuu.org.uk>
	<20070318142315.6f881ec8@lxorguk.ukuu.org.uk>
	<20070316153408.3a9a244a@lxorguk.ukuu.org.uk>
	<20070316151305.04cbc352@lxorguk.ukuu.org.uk>
	<20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<25571.1174054993@redhat.com>
	<26525.1174058071@redhat.com>
	<20070316171141.7a4de504@lxorguk.ukuu.org.uk>
	<076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
	<2578.1174305403@redhat.com>
	<3728.1174309154@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kyle Moffett <mrmacman_g4@mac.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:33004 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750988AbXCSO10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 10:27:26 -0400
In-Reply-To: <3728.1174309154@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Other RPC types use normal socket types.
> 
> They do?  Examples please.  I didn't think Linux, at least, has any other RPC
> socket families, though I could be wrong as I haven't made a thorough study of
> them.

SunRPC is implemented in user space and uses the existing TCP/IP layer
and socket types, even though it is using them in an RPC manner and
viewed at the RPC layer they are RPCs

>      I have made my client sockets use connect(), but that's just a convenience
>      and I need to make it possible to avoid doing that to make it useful to
>      the kernel.  It's similar to SOCK_DGRAM sockets in this respect.

So use SOCK_DGRAM, its clearly near enough.
