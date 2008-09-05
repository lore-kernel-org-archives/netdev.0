From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 5 Sep 2008 09:08:50 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0809050908160.17569@fbirervta.pbzchgretzou.qr>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain> <48C11918.8020508@trash.net> <48C11DF5.9040207@netfilter.org> <48C12526.90501@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34626 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbYIENIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 09:08:52 -0400
In-Reply-To: <48C12526.90501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2008-09-05 08:25, Patrick McHardy wrote:
>> > I hope so :) A different possiblity suggest by Pablo some time ago
>> > would be to mark untracked packets in skb->nfctinfo and not
>> > attach a conntrack at all.
>> 
>> Indeed, I remember that :). I left that patch of the table time ago [1].
>> There's a nf_reset call missing as Patrick said at that time. I can
>> recover it if you like the idea.
>
> I think that would be a good idea.

Would that work? Right now, a ct==NULL indicates the 'INVALID' state,
and overloading it with 'UNTRACKED' does not seem nice.
