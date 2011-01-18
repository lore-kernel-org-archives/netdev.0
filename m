From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
	of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 10:24:37 +0000
Message-ID: <20110118102437.GB7520@ff.dom.local>
References: <4D336050.9030602@netfilter.org> <20110118093811.GA7520@ff.dom.local> <20110118.020702.115924992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43004 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab1ARKYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 05:24:46 -0500
Received: by fxm20 with SMTP id 20so7023489fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 02:24:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110118.020702.115924992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 02:07:02AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 18 Jan 2011 09:38:11 +0000
> 
> > Even if I'm wrong, this change added to stable will break many configs.
> > My proposal is to revert commit 0ab03c2b147 until proper fix is found.
> 
> The flag combination is, at best ambiguous, it has no proper
> definition without the check we added.

Do you all expect all users manage to upgrade avahi app before
changing their stable kernel? I mean "own distro" users especially.

Jarek P.
