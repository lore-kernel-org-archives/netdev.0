From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:30:55 +0200
Message-ID: <44D1C24F.2080403@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801220338.GA11032@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44539 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932428AbWHCJa5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:30:57 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801220338.GA11032@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Jul 31, 2006 at 08:36:58PM +0200, Patrick McHardy wrote:
> 
>>diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
>>index 662a869..df1f4e5 100644
>>--- a/net/netfilter/nf_queue.c
>>+++ b/net/netfilter/nf_queue.c
> 
> 
> I presume we need similar patches for the old ipv4/ipv6 versions as well?

This is code is used for all queueing mechanisms, so they are already
covered by this.
