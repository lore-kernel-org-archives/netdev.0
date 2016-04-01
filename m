From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 01 Apr 2016 14:33:58 -0400 (EDT)
Message-ID: <20160401.143358.1963393066215816255.davem@davemloft.net>
References: <20160401042655.GA16500@ast-mbp.thefacebook.com>
	<56FDFA0F.5070104@stressinduktion.org>
	<56FE2CE3.9080805@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	sasha.levin@oracle.com, mkubecek@suse.cz
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcDASeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:34:00 -0400
In-Reply-To: <56FE2CE3.9080805@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 01 Apr 2016 10:10:11 +0200

> Dave, do you need me to resubmit this one w/o changes:
> http://patchwork.ozlabs.org/patch/603903/ ?

I'll apply this and queue it up for -stable, thanks.
