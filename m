From: jamal <hadi@cyberus.ca>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 11:59:37 -0500
Message-ID: <1295456377.2184.2.camel@mojatatu>
References: <4D336050.9030602@netfilter.org>
	 <20110118093811.GA7520@ff.dom.local>
	 <20110118.020702.115924992.davem@davemloft.net>
	 <20110118102437.GB7520@ff.dom.local> <4D35F8A3.1010600@netfilter.org>
	 <20110118205507.GB4288@del.dom.local> <1295447286.2008.850.camel@mojatatu>
	 <20110119165413.GB1845@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43355 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab1ASQ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:59:41 -0500
Received: by vws16 with SMTP id 16so437531vws.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 08:59:40 -0800 (PST)
In-Reply-To: <20110119165413.GB1845@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 17:54 +0100, Jarek Poplawski wrote:
> On Wed, Jan 19, 2011 at 09:28:06AM -0500, jamal wrote:

> > So here is what i think the criteria should be:
> > 
> > If Avahi is popular and widely deployed (I dont use it anywhere), it
> > makes no sense to revert. 
> > A middle ground is: instead of rejecting the nonsense passed, maybe a
> > sane thing to do is a kernel warning for a period of time (sort of like
> > feature removal warnings).
> 
> I still don't understand why you call this the nonsense. 


gah! I already had plenty of caffeine when i typed that.
I meant to say "If Avahi is popular and widely deployed,
it makes sense to revert"

> There are
> two dump flags NLM_F_ROOT and NLM_F_MATCH plus for convenience
> NLM_F_DUMP as 2 in 1. Avahi uses these specific flags. Why would
> anybody have added these specific flags if they can never be used
> separately?
> 
> Aside from this question, if we still think it's the nonsense, a
> warning would be nicer.

That is what i was suggesting as well..

cheers,
jamal

