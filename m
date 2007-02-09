From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 12:31:23 +0000
Message-ID: <10385.1171024283@redhat.com>
References: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>  <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	herbert.xu@redhat.com, hch@infradead.org, arjan@infradead.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946429AbXBIMbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 07:31:37 -0500
In-Reply-To: <20070209.015539.53640067.yoshfuji@linux-ipv6.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> and make it sure to align on 64-bit word.

The first part of sockaddr_rxrpc is exactly 64 bits; then comes the transport
address, so that's okay.

> This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> Please use sockaddr_storage{} (or sockaddr{}, maybe),

Why can't I include sockaddr_in and sockaddr_in6 in sockaddr_rxrpc, btw?

> > That won't work.  That would then make the address larger than the maximum
> > size (ie: sizeof(struct sockaddr_storage)).
> 
> sockaddr{}, then...

But that's not big enough to hold a sockaddr_in6...

David
