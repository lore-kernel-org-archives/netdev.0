From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 10:12:33 +0200
Message-ID: <20091013081233.GB3874@1wt.eu>
References: <20091013050705.GA2194@1wt.eu> <4AD42B0F.8010809@gmail.com> <20091013.003506.67125018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50183 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933763AbZJMINO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 04:13:14 -0400
Content-Disposition: inline
In-Reply-To: <20091013.003506.67125018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2009 at 12:35:06AM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 13 Oct 2009 09:23:59 +0200
> 
> > I dont understand why you want to decrement rskq_defer_accept here.
> > We receive a pure ACK (wihout DATA).
> > We should receive exactly one such ACK.
> > (This is the third packet of the three way TCP handshake)
> > 
> > How this can solve the problem you mention ?
> > (ie, not sending an RST when we timeout the SYN_RECV session)
> 
> I'll hold off on this patch until Eric's comments are
> addressed, thanks.

I have replied, but let's wait for Eric's response.

Willy

