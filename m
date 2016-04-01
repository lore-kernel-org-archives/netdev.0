From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 01 Apr 2016 03:37:26 +0200
Message-ID: <1459474646.3751154.565322314.303C5B08@webmail.messagingengine.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDC143.5060507@stressinduktion.org>
 <1459473790.6473.247.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54749 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753297AbcDABh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:37:27 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 69E062029F
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 21:37:26 -0400 (EDT)
In-Reply-To: <1459473790.6473.247.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Apr 1, 2016, at 03:23, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 02:30 +0200, Hannes Frederic Sowa wrote:
> 
> > I fixed this one, I wait with review a bit and collapse some of the 
> > newer fixes into one and check and repost again tomorrow.
> 
> No change should be needed in TCP, once net/core/sock.c is fixed.
> 
> When someone fixes a lockdep issue, it should be mandatory to include in
> the changelog the lockdep splat, so that we can double check.

Yup, will do that. Every change will be a single patch with lockdep
report.

Thank you,
Hannes
