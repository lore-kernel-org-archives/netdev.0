From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Mon, 13 Apr 2015 08:39:04 -0700
Message-ID: <1428939544.3834.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150409.143727.1391401196320839634.davem@davemloft.net>
	 <20150409191441.GE20653@breakpoint.cc>
	 <20150409.170720.1374561715105253435.davem@davemloft.net>
	 <20150409212144.GH20653@breakpoint.cc>
	 <1428664454.10242.19.camel@googlemail.com>
	 <1428912255.6534.5.camel@googlemail.com>
	 <1428937760.6534.23.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: Sebastian Poehn <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34399 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbbDMPjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:39:07 -0400
Received: by iget9 with SMTP id t9so57975018ige.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:39:06 -0700 (PDT)
In-Reply-To: <1428937760.6534.23.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-13 at 17:09 +0200, Sebastian Poehn wrote:

> Principally the problem is that TPROXY cannot ensure that policy routing is
> working correctly. Florian suggested me to clean skb->sk in ip_forward. I even think
> dropping the frame is fine. Not sure if this is suited for mainline.

No objections from me, this looks very reasonable.
