From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 20:24:09 +0100
Message-ID: <20110119192409.GE1845@del.dom.local>
References: <4D336050.9030602@netfilter.org>
 <20110118093811.GA7520@ff.dom.local>
 <20110118.020702.115924992.davem@davemloft.net>
 <20110118102437.GB7520@ff.dom.local>
 <4D35F8A3.1010600@netfilter.org>
 <20110118205507.GB4288@del.dom.local>
 <1295447286.2008.850.camel@mojatatu>
 <20110119165413.GB1845@del.dom.local>
 <alpine.LNX.2.01.1101191858390.13633@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	arthur.marsh@internode.on.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45956 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab1ASTYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:24:15 -0500
Received: by ywl5 with SMTP id 5so473459ywl.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 11:24:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1101191858390.13633@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 07:04:06PM +0100, Jan Engelhardt wrote:
> 
> On Wednesday 2011-01-19 17:54, Jarek Poplawski wrote:
> >
> >I still don't understand why you call this the nonsense. There are
> >two dump flags NLM_F_ROOT and NLM_F_MATCH plus for convenience
> >NLM_F_DUMP as 2 in 1. Avahi uses these specific flags. Why would
> >anybody have added these specific flags if they can never be used
> >separately?
> 
> It looks like the authors' intentinos were to make NLM_F_MATCH not
> stop after a single entry has been found. So that sounds like dump,
> ok.
> 
> But NLM_F_ROOT does not quite strike me as a dump request. What if I
> wanted just a single item returned but still start at the root?

Hmm... Does it say about starting at the root?:

"          NLM_F_ROOT     Return the complete table instead of a
                          single entry."

> 
> Or asking from a different direction, what's NLM_F_ROOT good for
> when, say, struct rtmsg->rtm_table specifies (in rtnetlink) where to
> start? (Particularly, 0 for an "invisible root" that contains all
> tables.)

I can't say I understand these flags, but IMHO the main point is we
should respect them as separate, even if mostly unused and look like
unnecessary. (Unless there is really no other way of fixing this
genetlink bug.) If it were undocumented... but after all this the RFC.

Jarek P.
