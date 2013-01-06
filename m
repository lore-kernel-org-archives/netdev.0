From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 02:30:27 +0100
Message-ID: <20130106013027.GV16031@1wt.eu>
References: <20130105214958.GA19814@1wt.eu> <1357427926.1678.4771.camel@edumazet-glaptop> <20130105232913.GQ16031@1wt.eu> <1357430523.1678.4901.camel@edumazet-glaptop> <20130106005053.GS16031@1wt.eu> <1357435276.1678.5067.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37517 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618Ab3AFBad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 20:30:33 -0500
Content-Disposition: inline
In-Reply-To: <1357435276.1678.5067.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2013 at 05:21:16PM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 01:50 +0100, Willy Tarreau wrote:
> 
> > Yes, I've removed all zero counters in this short view for easier
> > reading (complete version appended at the end of this email). This
> > was after around 140 GB were transferred :
> 
> OK I only wanted to make sure skb were not linearized in xmit.
> 
> Could you try to disable CONFIG_COMPACTION ?

It's already disabled.

> ( This is the other thread mentioning this : "ppoll() stuck on POLLIN
> while TCP peer is sending" )

Ah interesting because these were some of the mm patches that I had
tried to revert.

Willy
