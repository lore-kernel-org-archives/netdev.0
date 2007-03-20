From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Tue, 20 Mar 2007 13:16:20 +0000
Message-ID: <20347.1174396580@redhat.com>
References: <20070319.121958.48807741.davem@davemloft.net>  <2578.1174305403@redhat.com> <3728.1174309154@redhat.com> <25752.1174318898@redhat.com>
Cc: alan@lxorguk.ukuu.org.uk, mrmacman_g4@mac.com,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbXCTNRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 09:17:01 -0400
In-Reply-To: <20070319.121958.48807741.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> David we're not looking for a precise match, so please stop
> discussing this in those terms.  We're looking for something
> close enough.

But we don't have one that's close.  Let me recap: according to Alan's
definitions, all (presumably all non-RAW) network services must either be
datagram services or stream services, and must be selectable from DGRAM, RDM,
SEQPACKET or STREAM.  RPC is neither.  Also, why does DCCP have its own type?
According to Alan's logic that's superfluous.

> The more and more I read Alan's arguments and your resistence to
> his logic,

Which is flawed...

> the more I side with Alan.  He's definitely right on all the basic counts
> here.

Well, perhaps *you* can explain why he's right then...

But, since you insist, I'll just remove any restrictions on the type and drop
SOCK_RPC.  Type 0 will serve just as well since there's only one choice to be
had anyway, and that's all there's likely to be.

David
