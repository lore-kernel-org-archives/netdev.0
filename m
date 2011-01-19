From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 19:04:06 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101191858390.13633@obet.zrqbmnf.qr>
References: <4D336050.9030602@netfilter.org> <20110118093811.GA7520@ff.dom.local> <20110118.020702.115924992.davem@davemloft.net> <20110118102437.GB7520@ff.dom.local> <4D35F8A3.1010600@netfilter.org> <20110118205507.GB4288@del.dom.local> <1295447286.2008.850.camel@mojatatu>
 <20110119165413.GB1845@del.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	arthur.marsh@internode.on.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:58920 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab1ASSEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 13:04:07 -0500
In-Reply-To: <20110119165413.GB1845@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2011-01-19 17:54, Jarek Poplawski wrote:
>
>I still don't understand why you call this the nonsense. There are
>two dump flags NLM_F_ROOT and NLM_F_MATCH plus for convenience
>NLM_F_DUMP as 2 in 1. Avahi uses these specific flags. Why would
>anybody have added these specific flags if they can never be used
>separately?

It looks like the authors' intentinos were to make NLM_F_MATCH not
stop after a single entry has been found. So that sounds like dump,
ok.

But NLM_F_ROOT does not quite strike me as a dump request. What if I
wanted just a single item returned but still start at the root?

Or asking from a different direction, what's NLM_F_ROOT good for
when, say, struct rtmsg->rtm_table specifies (in rtnetlink) where to
start? (Particularly, 0 for an "invisible root" that contains all
tables.)

