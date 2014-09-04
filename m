From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] qdisc: exit case fixes for skb list handling
 in qdisc layer
Date: Wed, 03 Sep 2014 22:24:19 -0700
Message-ID: <1409808259.26422.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409671557.3173.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140903101250.7668.91659.stgit@dragon>
	 <20140903.204256.1398300065789241714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:43892 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414AbaIDFYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 01:24:22 -0400
Received: by mail-pd0-f176.google.com with SMTP id w10so3398574pde.35
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 22:24:22 -0700 (PDT)
In-Reply-To: <20140903.204256.1398300065789241714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 20:42 -0700, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Wed, 03 Sep 2014 12:12:50 +0200
> 
> > More minor fixes to merge commit 53fda7f7f9e (Merge branch 'xmit_list')
> > that allows us to work with a list of SKBs.
> > 
> > Fixing exit cases in qdisc_reset() and qdisc_destroy(), where a
> > leftover requeued SKB (qdisc->gso_skb) can have the potential of
> > being a skb list, thus use kfree_skb_list().
> > 
> > This is a followup to commit 10770bc2d1 ("qdisc: adjustments for
> > API allowing skb list xmits").
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> Applied.

Strange, I sent same patch a little earlier ;)
