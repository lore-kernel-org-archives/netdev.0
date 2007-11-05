From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 5 Nov 2007 15:49:59 +0100
Message-ID: <20071105144959.GD1933@ff.dom.local>
References: <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost> <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl> <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost> <20071105091231.GA1933@ff.dom.local> <1194267561.2987.141.camel@localhost.localdomain> <1194270212.4438.95.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:56017 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750877AbXKEOqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 09:46:13 -0500
Content-Disposition: inline
In-Reply-To: <1194270212.4438.95.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 08:43:32AM -0500, jamal wrote:
> On Mon, 2007-05-11 at 14:59 +0200, Radu Rendec wrote:
> > Jarek, thanks for replying my message on the list and pointing it to the
> > right direction.
> > 
> > Your example with "1" bits laying on exact nibble boundary is much
> > easier to analyze than my original example. And your computation seems
> > to be right: u32_hash_fold() would return 00.f0.00.0f (and would be cut
> > off to 0f after applying the divisor mask).
> 
> Yes, that example i believe would work just fine today as is with no
> changes.
...
> Please try the patch i sent since it is simpler. It is your work more or
> less - so you should get the credit as author. 

Jamal + Houston, we have a problem...
...Or talk about different things or patches...

IMHO, both 'today as is' and your 1-st proposal get this example
wrong: we need 00.00.00.ff at the end, don't we? 

Jarek P.
