From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Mon, 15 Aug 2011 11:25:01 -0700
Message-ID: <20110815112501.3a3c01ad@nehalam.ftrdhcpuser.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
	<20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
	<20110712113643.GC616804@jupiter.n2.diac24.net>
	<CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
	<20110715160357.GC1407585@jupiter.n2.diac24.net>
	<20110715163345.GD1407585@jupiter.n2.diac24.net>
	<20110727111714.GA2027462@jupiter.n2.diac24.net>
	<20110728084106.22166324@nehalam.ftrdhcpuser.net>
	<CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58678 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751302Ab1HOS0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 14:26:14 -0400
In-Reply-To: <CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2011 17:27:12 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> On 28 July 2011 16:41, Stephen Hemminger
> <shemminger@linux-foundation.org> wrote:
> > On Wed, 27 Jul 2011 13:17:15 +0200
> > David Lamparter <equinox@diac24.net> wrote:
> >
> >> On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wrote:
> >> > On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter wrote:
> >> > > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
> >> > > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
> >> > > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
> >> > > > >> I am still undecided on this. Understand the need, but don't like idea
> >> > > > >> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
> >> > > > >> has any input.
> >> > > > >
> >> > > > > The patch doesn't make the bridge behave nonconformant. The default mask
> >> > > > > is 0, which just keeps the old behaviour.
> >> >
> >> > P.S.: I'd like to once more stress this. In my opinion the patch should
> >> > be merged because it provides desireable functionality at a small cost
> >> > (one test, one knob) and __does not change any default behaviour__.
> >>
> >> Stephen, anything new on this?
> >
> > No.
> > Don't like adding yet another hack user visible API which will have
> > to be maintained for too long. But on the other hand I don't have
> > a better solution at my finger tips. If better idea doesn't come
> > along, then we can go with yours.
> >
> I have not noticed any other proposals and this thread has been open
> for quite a while.  Have we waited long enough ? If so can this patch
> be taken ?
> 

I am testing an alternative. The problem with your proposal is that
it relies on the multicast address. It turns out there are people using
other addresses for the STP group address, so using that as a identifier
is incorrect.

