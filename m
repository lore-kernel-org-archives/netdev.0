From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 14:29:25 +0100
Message-ID: <20150302132925.GB7418@breakpoint.cc>
References: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53336 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754285AbbCBN3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 08:29:30 -0500
Content-Disposition: inline
In-Reply-To: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eyal Birger <eyal.birger@gmail.com> wrote:
> This patch set introduces a new socket option for fetching the mark
> of skbs passed to sockets as ancillary data.
> 
> A userspace program may wish to receive the mark of packets it
> receives, for example for distinguishing between different TPROXY
> diversion rules to the same userspace proxy socket.

Hmm... Whats the use case?
Even if you cannot use multiple sockets for every divert rule,
TPROXY doesn't mangle payload; applications could use sockaddrs
returned by accept, getpeername, getsockname etc.  to figure out
which original port/address the packet was sent to?
