From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Thu, 21 May 2015 16:59:15 +0200
Message-ID: <1432220355.2547584.274841905.2944054B@webmail.messagingengine.com>
References: <cover.1432200343.git.hannes@stressinduktion.org>
 <1cd0796801936fb583e66a719597035ea779f534.1432200344.git.hannes@stressinduktion.org>
 <1432218198.4060.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49622 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755288AbbEUO7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:59:16 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 0A13720E53
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 10:59:16 -0400 (EDT)
In-Reply-To: <1432218198.4060.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015, at 16:23, Eric Dumazet wrote:
> On Thu, 2015-05-21 at 11:39 +0200, Hannes Frederic Sowa wrote:
> > unix_stream_recvmsg is refactored to unix_stream_read_generic in this
> > patch and enhanced to deal with pipe splicing. The refactoring is
> > inneglible, we mostly have to deal with a non-existing struct msghdr
> > argument.
> > 
> 
> > +static __always_inline
> > +int unix_stream_read_generic(struct unix_stream_read_state *state)
> >  {
> 
> 
> I do not believe it is reasonable to inline this monster, even if some
> macro benchmark looks better.
> 
> General trend in the community is to remove all these inlines.

Okay, I tend to agree and will remove it. Send v3 soon.

> ip_finish_output2() for example should lose its 'inline' keyword.

Ack.

Thanks,
Hannes
