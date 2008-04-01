From: Simon Horman <horms@verge.net.au>
Subject: Re: Adding IPv6 support to IPVS: some general questions about
	kernel development
Date: Tue, 1 Apr 2008 14:20:05 +0900
Message-ID: <20080401052003.GC21127@verge.net.au>
References: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com> <47F123C5.70804@trash.net> <f4845fc0803311129w4bdb0415p56c3f11c935c3020@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:43746 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbYDAFUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 01:20:06 -0400
Content-Disposition: inline
In-Reply-To: <f4845fc0803311129w4bdb0415p56c3f11c935c3020@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2008 at 08:29:30PM +0200, Julius Volz wrote:
> On Mon, Mar 31, 2008, Patrick McHardy <kaber@trash.net> wrote:
> >  net/ipvs or net/netfilter/ipvs sound fine. The second is probably
> >  better since at some point we should try to merge the duplicated
> >  conntrack functionality if possible.
> 
> Sure, since IPVS is basically a netfilter extension, that sounds good
> to me. Could all the IPv4- and IPv6-specific functionality (as opposed
> to the commonly used code) also end up in there or would that still
> have to reside under ipv[4,6]/...?
> 
> Does it seem wise to do this move as the first thing in this process?
> That would probably be a good starter exercise to get to know the
> whole process!

I think that sounds like an excellent idea. net/netfilter/ipvs sounds
fine to me, though think that IPVS is fairly loosely tied to nefilter,
so if it was only up to me I would go for net/ipvs.

-- 
Horms

