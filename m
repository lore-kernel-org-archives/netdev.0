From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Wed, 28 Nov 2012 03:55:12 +0000
Message-ID: <1354074912.2701.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
	 <1354072351.2701.41.camel@bwh-desktop.uk.solarflarecom.com>
	 <1354073514.8918.22.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14962 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab2K1DzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 22:55:16 -0500
In-Reply-To: <1354073514.8918.22.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 19:31 -0800, Joe Perches wrote:
> On Wed, 2012-11-28 at 03:12 +0000, Ben Hutchings wrote:
> > On Tue, 2012-11-27 at 18:23 -0800, Joe Perches wrote:
> > > OK, so it's an and not an or.  Duh.
> > [...]
> > 
> > The way to combine these sorts of comparisons is along the lines of:
> > 
> > (((left->a ^ right->a) |
> >   (left->b ^ right->b) |
> >   ...) == 0)
> > 
> > But when there are big-endian types involved, sparse is likely to
> > complain about combining them.
> 
> I believe there's only the 2 items that could be combined
> for cacheline purposes so using 2 logical tests with AND
> seems more readable.  Maybe a single combined test would
> be faster.  I don't have equipment at hand to test it.
> 
> If you prefer I supposed it could be converted.

I don't particularly care, and I gave up this trick myself because it
didn't seem worth fighting sparse.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
