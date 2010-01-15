From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 10:00:11 +0100
Message-ID: <20100115100011.076505bf@marrow.netinsight.se>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com>
	<20100115.003636.199394610.davem@davemloft.net>
	<20100115095049.14190a50@marrow.netinsight.se>
	<20100115.005224.257449393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:60356 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752085Ab0AOJAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:00:18 -0500
In-Reply-To: <20100115.005224.257449393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2010 00:52:24 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > The same thing goes for via-velocity.c, it's turned on via ethtool
> > though (ethtool_op_set_sg).
> 
> Indeed, see my reply to Krishna's ethtool_op_set_sg() patch.
> 
> I think it's a cruddy way to do things, SG ought to be on by
> default always unless it is defective.  And if it's defective
> support should be removed entirely.

I kept it off by default since I didn't see any big improvement in my
tests (negative in some, positive in some). But I suppose you're
right though.

// Simon
