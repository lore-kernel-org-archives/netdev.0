From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Fri, 03 May 2013 07:03:07 -0700
Message-ID: <1367589787.29805.23.camel@edumazet-glaptop>
References: <1366786204.5977.10.camel@marge.simpson.net>
	 <1366853695.8964.120.camel@edumazet-glaptop>
	 <1366865490.4595.22.camel@marge.simpson.net>
	 <1366866233.8964.128.camel@edumazet-glaptop>
	 <20130426105030.GE20927@linutronix.de>
	 <1367455779.30667.113.camel@gandalf.local.home>
	 <20130503082058.GA8230@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:39686 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433Ab3ECODU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:03:20 -0400
In-Reply-To: <20130503082058.GA8230@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 10:20 +0200, Sebastian Andrzej Siewior wrote:
> * Steven Rostedt | 2013-05-01 20:49:39 [-0400]:
> 
> >Is this something going into the stable tree, or does it not affect 3.0,
> >3.2, 3.4 or 3.6?
> 
> Mike Galbraith reported it against v3.6 so I would say that this is one
> candidate. I just booted v3.4.41-rt55 and it runs for 20 minutes now
> without any issues. Maybe it crashes after I sent the email but I hope
> it does not :)

Thats because the particular way to trigger the bug was to use the IP
early demux, and it was added in 3.5
