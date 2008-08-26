From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix dev_graft_qdisc() locking
Date: Tue, 26 Aug 2008 13:05:36 +0000
Message-ID: <20080826130536.GC5991@ff.dom.local>
References: <20080825224854.GA12082@ami.dom.local> <E1KXxy1-0000kI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:37698 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbYHZNFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 09:05:42 -0400
Received: by ug-out-1314.google.com with SMTP id c2so734251ugf.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 06:05:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1KXxy1-0000kI-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 10:48:13PM +1000, Herbert Xu wrote:
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> > pkt_sched: Fix dev_graft_qdisc() locking
> > 
> > During dev_graft_qdisc() dev is deactivated, so qdisc_root_lock()
> > returns wrong lock of noop_qdisc instead of qdisc_sleeping.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Looks good to me!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 

BTW, I should've probably mention this lock doesn't probably
matter here much, after current precise deactivation.

Thanks,
Jarek P.
