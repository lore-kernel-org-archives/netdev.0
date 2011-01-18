From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 21:55:07 +0100
Message-ID: <20110118205507.GB4288@del.dom.local>
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
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38745 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839Ab1ARUzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 15:55:13 -0500
Received: by eye27 with SMTP id 27so41477eye.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 12:55:12 -0800 (PST)
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

I don't agree as explained in the reverting patch. Anyway, again,
this is an old problem, so no reason to force "fixing" it just now
at the expense of the obvious regression especially in stable kernels
Anyway, I'll accept any David's decision wrt this problem.

Jarek P.
