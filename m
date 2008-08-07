From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 7 Aug 2008 10:31:30 +0000
Message-ID: <20080807103130.GA12654@ff.dom.local>
References: <20080806.202636.246995904.davem@davemloft.net> <20080806.220911.91192536.davem@davemloft.net> <20080807100910.GA12391@ff.dom.local> <20080807.031058.193703340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:8236 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756593AbYHGNHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 09:07:35 -0400
Received: by ug-out-1314.google.com with SMTP id h2so331638ugf.16
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 06:07:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080807.031058.193703340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 03:10:58AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 7 Aug 2008 10:09:10 +0000
...
> > After some checking it looks mostly OK to me, but one thing: in
> > sch_gred gred_drop() calls qdisc_drop(), so now it needs kfree_skb().
> > BTW, maybe it would be nicer to add __qdisc_drop() for these new
> > things?
> 
> qdisc_drop() sets the new __NET_XMIT_KFREE bit, but sch_gred wants to
> return NET_XMIT_CN, so I OR'd in the __NET_XMIT_KFREE bit there.

Hmm... I'm not sure we're thinking about the same function?

Jarek P.
