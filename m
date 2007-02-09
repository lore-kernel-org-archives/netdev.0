From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 10:31:34 +0000
Message-ID: <7426.1171017094@redhat.com>
References: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>  <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	herbert.xu@redhat.com, hch@infradead.org, arjan@infradead.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33457 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946315AbXBIKbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 05:31:50 -0500
In-Reply-To: <20070209.015539.53640067.yoshfuji@linux-ipv6.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> Please use sockaddr_storage{} (or sockaddr{}, maybe), and make it
> sure to align on 64-bit word.

That won't work.  That would then make the address larger than the maximum
size (ie: sizeof(struct sockaddr_storage)).

David
