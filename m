From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 10:56:57 +0000
Message-ID: <20150317105657.GE11089@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48193 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbbCQK5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 06:57:00 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/15 at 10:51am, David Laight wrote:
> Looks like you could pre-calculate the 'grow_at' size.
> The test above would then be:
> 	return atomic_read(&ht->nelems > tbl->grow_at_size);
> 
> Similarly for the shrink.

Given the discussions, the grow decision will likely change to
a max bucket length limit anyway.
