From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: generalize MAX_TCP_HEADER usage
Date: Sat, 29 Mar 2014 15:47:26 -0700
Message-ID: <1396133246.21428.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395951546.12610.317.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140329.175654.1000726174039601620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:53873 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbaC2Wr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:47:29 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so6498564pbc.7
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 15:47:28 -0700 (PDT)
In-Reply-To: <20140329.175654.1000726174039601620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-29 at 17:56 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 27 Mar 2014 13:19:06 -0700
> 
> > (Note that sk_stream_alloc_skb() uses MAX_TCP_HEADER anyway...)
> 
> But only after your changes.
> 
> Please make this clear in the commit message, I had to go check to see
> if there were in fact MAX_TCP_HEADER uses in sk_stream_alloc_skb in
> the current tree.

Yeah, lets leave sk_stream_alloc_skb() as it is (even it is only used by
TCP).

What I meant is that sk_stream_alloc_skb() uses MAX_TCP_HEADER (for
TCP), so tcp_xmit_size_goal() should not be picky.
