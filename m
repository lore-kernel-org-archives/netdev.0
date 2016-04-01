From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 01 Apr 2016 03:36:58 +0200
Message-ID: <1459474618.3751123.565321858.30DF1858@webmail.messagingengine.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41240 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753675AbcDABg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:36:59 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 637ED20B09
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 21:36:58 -0400 (EDT)
In-Reply-To: <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016, at 03:19, Eric Dumazet wrote:
> Thanks.
> 
> As you can see, release_sock() messes badly lockdep (once your other
> patches are in )
> 
> Once we properly fix release_sock() and/or __release_sock(), all these
> false positives disappear.

This was a loopback connection. I need to study release_sock and
__release_sock more as I cannot currently see an issue with the lockdep
handling.
