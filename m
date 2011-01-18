From: David Miller <davem@davemloft.net>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 12:50:51 -0800 (PST)
Message-ID: <20110118.125051.260099262.davem@davemloft.net>
References: <20110118.020702.115924992.davem@davemloft.net>
	<20110118102437.GB7520@ff.dom.local>
	<4D35F8A3.1010600@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752168Ab1ARUuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 15:50:17 -0500
In-Reply-To: <4D35F8A3.1010600@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 18 Jan 2011 21:31:31 +0100

> The combination that avahi uses makes no sense.
> 
> I've been auditing user-space tools that may have problems with this change:
> 
> * iw (it uses libnl)
> * acpid (it uses a mangled version of libnetlink shipped in iproute)
> * tstime, for taskstats, it uses libnl
> * wimax-tools, it uses libnl
> * quota-tools, it uses libnl
> * keepalived, no libs used
> 
> Well, I can keep looking for more, but I think that avahi is the only
> one doing this incorrectly.
> 
> Please, fix avahi instead.

That's a pretty compelling argument, so I'll hold off on the revert
for now.
