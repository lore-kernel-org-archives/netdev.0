From: Andy Gay <andy@andynet.net>
Subject: Re: RDMA will be reverted
Date: Tue, 04 Jul 2006 19:48:29 -0400
Message-ID: <1152056909.3285.617.camel@tahini.andynet.net>
References: <adawtazgawi.fsf@cisco.com> <200607042247.12296.ak@suse.de>
	<1152051753.3285.600.camel@tahini.andynet.net>	<200607050101.12476.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:63711 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S932361AbWGDXsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 19:48:38 -0400
Received: from andyhp.tranquilitynj.net ([141.150.87.80])
 by vms048.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J1W00LEUKSVOQI8@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 04 Jul 2006 18:48:32 -0500 (CDT)
In-reply-to: <200607050101.12476.ak@suse.de>
To: Andi Kleen <ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-05 at 01:01 +0200, Andi Kleen wrote:
> > My point wasn't really about performance here, more that systems needing
> > this level of performance (server farm is just an example) will probably
> > be on an 'inside' network with firewalling being done elsewhere (at the
> > access layer, to use the Cisco paradigm). It's just not good design to
> > attach such systems directly to an untrusted network, IMHO. So these
> > systems just don't need netfilter capabilities.
> 
> Don't think of the highend. It is exotic and rare.
Sure. But isn't the high end exactly where these new technologies are
intended to fit?

> 
> Think of the ordinary single linux box somewhere at a rackspace provider which 
> represents the majority of Linux boxes around. 
How many of those need 10G nics?

> 
> With a not too skilled admin who mostly uses the default settings of his configuration.
> For that running firewalling on the same box makes a lot of sense.
Yup. I run a few of those. And I run firewalls on them. But they're on
1.5M T1 pipes at best.
I probably fit into your 'not too skilled' category, too :) 

> 
> Normally it is not that loaded and it doesn't matter much how it performs,
> but it might be occasionally slashdotted and then it should still hold up.
> 
> BTW basic firewalling is not really that bad as long as you don't have too many
> rules. Mostly conntrack is painful right now. I'm sure at some point it will
> be fixed too.
Actually, I wasn't aware of any pain with conntrack, it works great for
me. But like I said, I don't run any real high speed connections.

We're focusing on netfilter here. Is breaking netfilter really the only
issue with this stuff? I know you mentioned some other concerns (about
TOE specifically), they were really scalability things though weren't
they - like you're not convinced this really solves any performance
issues long term. I'm certainly not qualified to discuss that, hopefully
some of the others will weigh in here.

> 
> -Andi
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

