From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation attempts
Date: Fri, 20 Feb 2015 14:31:20 +0000
Message-ID: <20150220143120.GE4586@casper.infradead.org>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
 <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52112 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbBTObY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:31:24 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 02:27pm, David Laight wrote:
> I presume this code is allocating very large arrays for the base of the hash lists.
> Since there is no absolute requirement for contiguous KVA (nothing
> sequentially accesses the entire array) it can be coded differently.
> 
> I realize that this would involve an extra data cache line access.
> So you'd want to avoid it for small tables.
> (I expected this to be your objection)

We can consider switching over to flex arrays at some point
although NUMA considerations seem much more important to me
at this point.
