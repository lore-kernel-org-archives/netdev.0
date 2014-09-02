From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/3] qdisc: adjustments for API allowing skb
 list xmits
Date: Tue, 02 Sep 2014 08:25:57 -0700
Message-ID: <1409671557.3173.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140902143254.1918.8419.stgit@dragon>
	 <20140902143524.1918.70967.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:49237 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbaIBP0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 11:26:03 -0400
Received: by mail-pd0-f175.google.com with SMTP id ft15so8911924pdb.34
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 08:26:02 -0700 (PDT)
In-Reply-To: <20140902143524.1918.70967.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-02 at 16:35 +0200, Jesper Dangaard Brouer wrote:
> Minor adjustments for merge commit 53fda7f7f9e (Merge branch 'xmit_list')
> that allows us to work with a list of SKBs.
> 
> Update code doc to function sch_direct_xmit().
> 
> In handle_dev_cpu_collision() use kfree_skb_list() in error handling.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Please fix all other similar issues in a single patch.

qdisc_reset() and qdisc_destroy() are buggy as well.
