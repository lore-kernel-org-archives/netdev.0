From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: nfnetlink_queue: zero copy support
Date: Tue, 19 Mar 2013 23:52:43 +0100
Message-ID: <20130319225243.GA3657@localhost>
References: <1363576555.29475.122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34747 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755601Ab3CSWws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 18:52:48 -0400
Content-Disposition: inline
In-Reply-To: <1363576555.29475.122.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 17, 2013 at 08:15:55PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> nfqnl_build_packet_message() actually copy the packet
> inside the netlink message, while it can instead use
> zero copy.
> 
> Make sure the skb 'copy' is the last component of the
> cooked netlink message, as we cant add anything after it.
> 
> Patch cooked in Copenhagen at Netfilter Workshop ;)
> 
> Still to be addressed in separate patches :
> 
> -GRO/GSO packets are segmented in nf_queue()
> and checksummed in nfqnl_build_packet_message().
> 
> Proper support for GSO/GRO packets (no segmentation,
> and no checksumming) needs application cooperation, if we
> want no regressions.

Applied, thanks.
