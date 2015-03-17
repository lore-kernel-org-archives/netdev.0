From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 11:22:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB02510@AcuExch.aculab.com>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	"tgraf@suug.ch" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:59841 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbCQLYA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 07:24:00 -0400
In-Reply-To: <20150317110041.GA11385@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 17 March 2015 11:01
> On Tue, Mar 17, 2015 at 10:56:57AM +0000, tgraf@suug.ch wrote:
> >
> > Given the discussions, the grow decision will likely change to
> > a max bucket length limit anyway.
> 
> Actually no.  In my pathces the chain length is only used to
> force an immediate rehash.  Growing is still based on the number
> of elements.
> 
> The reason is that the maximum (not average) chain length actually
> grows with the hash table size, even at 75% utilisation.

That doesn't surprise me.

But won't the rehashed table be just as likely to have a long list?
So you are likely to get an immediate rehash?

	David
