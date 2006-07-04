From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Wed, 5 Jul 2006 01:01:12 +0200
Message-ID: <200607050101.12476.ak@suse.de>
References: <adawtazgawi.fsf@cisco.com> <200607042247.12296.ak@suse.de> <1152051753.3285.600.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52953 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932299AbWGDXBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 19:01:30 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1152051753.3285.600.camel@tahini.andynet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> My point wasn't really about performance here, more that systems needing
> this level of performance (server farm is just an example) will probably
> be on an 'inside' network with firewalling being done elsewhere (at the
> access layer, to use the Cisco paradigm). It's just not good design to
> attach such systems directly to an untrusted network, IMHO. So these
> systems just don't need netfilter capabilities.

Don't think of the highend. It is exotic and rare.

Think of the ordinary single linux box somewhere at a rackspace provider which 
represents the majority of Linux boxes around. 

With a not too skilled admin who mostly uses the default settings of his configuration.
For that running firewalling on the same box makes a lot of sense.

Normally it is not that loaded and it doesn't matter much how it performs,
but it might be occasionally slashdotted and then it should still hold up.

BTW basic firewalling is not really that bad as long as you don't have too many
rules. Mostly conntrack is painful right now. I'm sure at some point it will
be fixed too.

-Andi
