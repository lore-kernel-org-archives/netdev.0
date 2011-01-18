From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 22:14:50 +0100
Message-ID: <20110118211450.GC4288@del.dom.local>
References: <4D336050.9030602@netfilter.org>
 <20110118093811.GA7520@ff.dom.local>
 <20110118.020702.115924992.davem@davemloft.net>
 <20110118102437.GB7520@ff.dom.local>
 <4D35F8A3.1010600@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43727 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab1ARVbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 16:31:22 -0500
Received: by fxm20 with SMTP id 20so116884fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 13:31:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D35F8A3.1010600@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 09:31:31PM +0100, Pablo Neira Ayuso wrote:
> On 18/01/11 11:24, Jarek Poplawski wrote:
> > On Tue, Jan 18, 2011 at 02:07:02AM -0800, David Miller wrote:
> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> Date: Tue, 18 Jan 2011 09:38:11 +0000
> >>
> >>> Even if I'm wrong, this change added to stable will break many configs.
> >>> My proposal is to revert commit 0ab03c2b147 until proper fix is found.
> >>
> >> The flag combination is, at best ambiguous, it has no proper
> >> definition without the check we added.
> > 
> > Do you all expect all users manage to upgrade avahi app before
> > changing their stable kernel? I mean "own distro" users especially.
> 
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

BTW, could you answer my earlier question, why NLM_F_ATOMIC flag isn't
handled now with dumps?

Jarek P.
