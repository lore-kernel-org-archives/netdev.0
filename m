From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 17:54:13 +0100
Message-ID: <20110119165413.GB1845@del.dom.local>
References: <4D336050.9030602@netfilter.org>
 <20110118093811.GA7520@ff.dom.local>
 <20110118.020702.115924992.davem@davemloft.net>
 <20110118102437.GB7520@ff.dom.local>
 <4D35F8A3.1010600@netfilter.org>
 <20110118205507.GB4288@del.dom.local>
 <1295447286.2008.850.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35904 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108Ab1ASQyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:54:20 -0500
Received: by yxt3 with SMTP id 3so335330yxt.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 08:54:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1295447286.2008.850.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 09:28:06AM -0500, jamal wrote:
> On Tue, 2011-01-18 at 21:55 +0100, Jarek Poplawski wrote:
> > On Tue, Jan 18, 2011 at 09:31:31PM +0100, Pablo Neira Ayuso wrote:
> 
> > > The combination that avahi uses makes no sense.
> > 
> > I don't agree as explained in the reverting patch. Anyway, again,
> > this is an old problem, so no reason to force "fixing" it just now
> > at the expense of the obvious regression especially in stable kernels
> > Anyway, I'll accept any David's decision wrt this problem.
> > 
> 
> So here is what i think the criteria should be:
> 
> If Avahi is popular and widely deployed (I dont use it anywhere), it
> makes no sense to revert. 
> A middle ground is: instead of rejecting the nonsense passed, maybe a
> sane thing to do is a kernel warning for a period of time (sort of like
> feature removal warnings).

I still don't understand why you call this the nonsense. There are
two dump flags NLM_F_ROOT and NLM_F_MATCH plus for convenience
NLM_F_DUMP as 2 in 1. Avahi uses these specific flags. Why would
anybody have added these specific flags if they can never be used
separately?

Aside from this question, if we still think it's the nonsense, a
warning would be nicer.

Cheers,
Jarek P.
