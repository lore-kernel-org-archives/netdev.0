From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Fri, 5 Jul 2013 00:12:12 +0200
Message-ID: <20130704221212.GA23735@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130704.143103.1546241224422474244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34412 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933159Ab3GDWMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jul 2013 18:12:18 -0400
Content-Disposition: inline
In-Reply-To: <20130704.143103.1546241224422474244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 04, 2013 at 02:31:03PM -0700, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 4 Jul 2013 19:35:52 +0200
> 
> > From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Sat, 15 Jun 2013 23:25:15 +0200
> > Subject: [PATCH] net: convert mvneta to build_skb()
> > 
> > We store the frag_size in the mvneta_port struct. In practice we'd need
> > a single bit to know how to free the data, but since we need the size to
> > call build_skb() anyway, let's store the full size.
> > 
> > With this patch, I observed a reproducible 2% performance improvement on
> > HTTP-based benchmarks.
> > 
> > Signed-off-by: Willy Tarreau <w@1wt.eu>
> 
> The net-next tree is closed now that the merge window is open, therefore
> submissions such as this are not appropriate at this time.
> 
> Please resubmit this when net-next opens again, an event which I will
> clearly announce here on netdev.

OK no problem, thanks.

Willy
