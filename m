From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Tue, 20 Mar 2007 11:16:45 +0000
Message-ID: <12125.1174389405@redhat.com>
References: <20070319190306.44f9a2e5@lxorguk.ukuu.org.uk>  <20070319152959.46a81e57@lxorguk.ukuu.org.uk> <20070319130428.4b645207@lxorguk.ukuu.org.uk> <20070318142315.6f881ec8@lxorguk.ukuu.org.uk> <20070316153408.3a9a244a@lxorguk.ukuu.org.uk> <20070316151305.04cbc352@lxorguk.ukuu.org.uk> <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <25571.1174054993@redhat.com> <26525.1174058071@redhat.com> <20070316171141.7a4de504@lxorguk.ukuu.org.uk> <076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com> <2578.1174305403@redhat.com> <3728.1174309154@redhat.com> <25752.1174318898@redhat.com>
Cc: Kyle Moffett <mrmacman_g4@mac.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbXCTLRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 07:17:01 -0400
In-Reply-To: <20070319190306.44f9a2e5@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> O> No, it's not.  SOCK_DGRAM is an unreliable, unidirectional datagram passing
> > service.
> 
> Thats funny UDP receives and sends packets.

I meant that the protocol ships a datagram from one peer to another, but
there's no tie at the protocol level to any datagrams going the other way.

David
