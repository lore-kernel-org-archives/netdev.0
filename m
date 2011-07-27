From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Wed, 27 Jul 2011 13:17:15 +0200
Message-ID: <20110727111714.GA2027462@jupiter.n2.diac24.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
 <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
 <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
 <20110712113643.GC616804@jupiter.n2.diac24.net>
 <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
 <20110715160357.GC1407585@jupiter.n2.diac24.net>
 <20110715163345.GD1407585@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net, David Lamparter <equinox@diac24.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:43941 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382Ab1G0LRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 07:17:24 -0400
Content-Disposition: inline
In-Reply-To: <20110715163345.GD1407585@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wrote:
> On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter wrote:
> > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
> > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
> > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
> > > >> I am still undecided on this. Understand the need, but don't like idea
> > > >> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
> > > >> has any input.
> > > >
> > > > The patch doesn't make the bridge behave nonconformant. The default mask
> > > > is 0, which just keeps the old behaviour.
> 
> P.S.: I'd like to once more stress this. In my opinion the patch should
> be merged because it provides desireable functionality at a small cost
> (one test, one knob) and __does not change any default behaviour__.

Stephen, anything new on this?

-David
