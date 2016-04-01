From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 18:23:10 -0700
Message-ID: <1459473790.6473.247.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
	 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
	 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDBA6E.5030508@stressinduktion.org>
	 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDC143.5060507@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32879 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbcDABXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:23:13 -0400
Received: by mail-pa0-f47.google.com with SMTP id zm5so78425733pac.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 18:23:13 -0700 (PDT)
In-Reply-To: <56FDC143.5060507@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 02:30 +0200, Hannes Frederic Sowa wrote:

> I fixed this one, I wait with review a bit and collapse some of the 
> newer fixes into one and check and repost again tomorrow.

No change should be needed in TCP, once net/core/sock.c is fixed.

When someone fixes a lockdep issue, it should be mandatory to include in
the changelog the lockdep splat, so that we can double check.

Thanks.
