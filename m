From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #2]
Date: Mon, 19 Mar 2007 13:04:28 +0000
Message-ID: <20070319130428.4b645207@lxorguk.ukuu.org.uk>
References: <20070318142315.6f881ec8@lxorguk.ukuu.org.uk>
	<20070316153408.3a9a244a@lxorguk.ukuu.org.uk>
	<20070316151305.04cbc352@lxorguk.ukuu.org.uk>
	<20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<25571.1174054993@redhat.com>
	<26525.1174058071@redhat.com>
	<20070316171141.7a4de504@lxorguk.ukuu.org.uk>
	<076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
	<2578.1174305403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kyle Moffett <mrmacman_g4@mac.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50069 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753804AbXCSMBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 08:01:49 -0400
In-Reply-To: <2578.1174305403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> message transmission.  You yourself defined RDM to be a datagram service.
> RxRPC is not, in my opinion, a datagram service, and neither is it a stream
> service.

Message is what I should have said.

> Interestingly, searching for SOCK_RDM definitions with google shows there's
> some disagreement as to what it represents.  Some seem to thing it's connection
> oriented and some that it's connectionless, and some seem to think it's
> ordered, and some not.

Which is just fine, does it need to be one or the other. SOCK_DGRAM an be
both connection oriented or connectionless.

> 
> > > independent and possibly simultaneous RxRPC calls.  From the digging  
> > > around that I did in the kernel socket code a while ago I don't see a  
> > > cleaner way of implementing it than a new SOCK_RXRPC.
> 
> Well, I suggest SOCK_RPC, not SOCK_RXRPC.  There's no particular reason such a
> flow type has to be limited to RxRPC.

Other RPC types use normal socket types.

> I'd say that that precludes applicability on two points: firstly, RxRPC is not
> a datagram layer by the definition I provided in a previous email; and
> secondly, RxRPC *does* provide some ordering guarantees.

So you want SOCK_SEQPACKET perhaps then ?

> > What does AIX do out of interest ?
> 
> I've no way to find out what AIX does, but I suspect it simply doesn't.

Perhaps someone with AIX boxes around (say @ibm.com) could answer ?
