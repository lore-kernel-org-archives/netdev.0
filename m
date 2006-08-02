From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Wed, 02 Aug 2006 02:42:05 +0200
Message-ID: <m33bcgc6jm.fsf@defiant.localdomain>
References: <m3zmevqhgn.fsf@defiant.localdomain>
	<20060727164334.GA2779@ms2.inr.ac.ru>
	<m3fygjkpwb.fsf@defiant.localdomain>
	<20060801202503.GA30889@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43456 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1750874AbWHBAmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 20:42:07 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060801202503.GA30889@ms2.inr.ac.ru> (Alexey Kuznetsov's message of "Wed, 2 Aug 2006 00:25:03 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> Actually, it is historical hole in design, inherited from ancient
> times. Calling conventions of dev->hard_header() just did not allow
> to reallocate. BTW in 2.6 it can, if it uses pskb_expand_head().

Does that mean that hard_header() and then hard_start_xmit()
can use pskb_expand_head() instead of skb_realloc_headroom()
without restrictions?
-- 
Krzysztof Halasa
