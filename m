From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
	messages
Date: Wed, 15 Apr 2009 15:43:55 -0400
Message-ID: <20090415194355.GF21448@hmsreliant.think-freely.org>
References: <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org> <49E6172D.8080201@hp.com> <20090415175329.GE21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904151517540.18317@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47502 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbZDOToL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 15:44:11 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904151517540.18317@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 03:21:27PM -0400, Christoph Lameter wrote:
> On Wed, 15 Apr 2009, Neil Horman wrote:
> 
> > I can easily envision on application which expects to get multicast traffic that
> > doesn't join a group within the context of its own process, specifically relying
> > on the behavior as its documented today.  Consider a data processing
> > application whos group management is segmented into a different utility.  This
> > is really the problem here though isn't it?  A proposal to change the 20 year
> > old behavior of multicast reception with no way to know how strongly
> > applications rely on this behavior and no documentation to support the assertion
> > that the current behavior is broken.
> 
> The "utility" must be a daemon that keeps the socket open. You are
> talking about a sheperding process that first opens a socket and
> then performs multicast groups. It then keeps the socket open
> (otherwise would be unsubscribed) and starts other processes that then
> open their own sockets and expect the subscriptions to work.
> 
> That does not look convincing. Can you cite a case of an
> application actually depending on this behavior?
> 
No, of course not, since I'm just hypothesizing.  Of course that doesn't mean
they don't exist.  And by that token you can't predict what will happen to
applications that do rely (either explicitly or inadvertently) on the current
behavior.

None of which _really_ matters, anyway, they're applications, they can be fixed
to work with either.  The question really is, do we need to, and I think the
answer is no

> > I'll refer you again to this exact conversation months ago, when I was on the
> > opposite end of this, and shown to be wrong:
> > http://kerneltrap.org/mailarchive/linux-netdev/2008/7/11/2430904
> 
> Just you backing down does not mean that this is wrong. We have many
> more factiods here now.

No, it doesn't mean this is wrong, but it does mean David convinced me what we
have now is right.  I'm obviously not going to be able to pass that on to you,
so I'm done.  Perhaps he will pick this up, I've said my peace.

Neil

