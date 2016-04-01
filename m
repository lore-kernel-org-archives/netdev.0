From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 02:30:59 +0200
Message-ID: <56FDC143.5060507@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35143 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbcDAAbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 20:31:03 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 3ACF820C4B
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 20:31:02 -0400 (EDT)
In-Reply-To: <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 02:12, Eric Dumazet wrote:
> Since this function does not take a reference on the dst, how could it
> be safe ?
>
> As soon as you exit the function, dst would possibly point to something
> obsolete/freed.
>
> This works because the caller owns the socket.
>
> If you believe one path needs to be fixed, tell me which one it is.
>
> Please ?

I fixed this one, I wait with review a bit and collapse some of the 
newer fixes into one and check and repost again tomorrow.

Thanks for reviewing!

Bye,
Hannes
