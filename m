From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v4 PATCH 1/1] netfilter: Add fail-open support
Date: Thu, 24 May 2012 16:19:07 +0530
Message-ID: <OF40A553D6.951AAA8B-ON65257A08.003B5B83-65257A08.003B7B3A@in.ibm.com>
References: <20120524082518.13146.25740.sendpatchset@localhost.localdomain> <20120524082531.13146.347.sendpatchset@localhost.localdomain> <20120524101755.GF13091@1984> <20120524104156.GA13785@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	fw@strlen.de, kaber@trash.net, netdev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, sri@us.ibm.com,
	Sulakshan Vajipayajula <svajipay@in.ibm.com>, vivk@us.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:60960 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2EXKv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 06:51:29 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Thu, 24 May 2012 16:21:26 +0530
In-Reply-To: <20120524104156.GA13785@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote on 05/24/2012 04:11:56 PM:

> On Thu, May 24, 2012 at 12:17:55PM +0200, Pablo Neira Ayuso wrote:
> > My main objection with this patch is that it adds more code out of the
> > scope of the nf_queue handling to nf_hook_slow. And this is done for
> > very specific purpose.
> >
> > @David, @Eric: Krishna aims to provide a mechanism that can be enabled
> > to accept packets if the nfqueue becomes full, ie. it changes the
> > default behaviour under congestion from drop to accept. It seems some
> > users prefer not to block traffic under nfqueue congestion.
>
> Florian Westphal just proposed some possible interesting solution for
> this.

Yes, and I have just finished testing this and it works fine. With
this, all the changes are localized to nfnetlink_queue.c. I am doing
some more tests before resubmitting this.

thanks,
- KK
