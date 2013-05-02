From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Wed, 01 May 2013 20:49:39 -0400
Message-ID: <1367455779.30667.113.camel@gandalf.local.home>
References: <1366786204.5977.10.camel@marge.simpson.net>
	 <1366853695.8964.120.camel@edumazet-glaptop>
	 <1366865490.4595.22.camel@marge.simpson.net>
	 <1366866233.8964.128.camel@edumazet-glaptop>
	 <20130426105030.GE20927@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:19501 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab3EBAtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 20:49:41 -0400
In-Reply-To: <20130426105030.GE20927@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-26 at 12:50 +0200, Sebastian Andrzej Siewior wrote:
> * Eric Dumazet | 2013-04-24 22:03:53 [-0700]:
> 
> >On Thu, 2013-04-25 at 06:51 +0200, Mike Galbraith wrote:
> >
> >> Thanks for the fix.  I'll apply it and beat on the box some more (g.p.).
> >> Gripe only happened the one time during long workout day.
> >
> >To force it to happen, you need to invalidate the cached dst in socket.
> >
> >So presumably doing in the background some "ip ro ..." commands to
> >add/delete routes.
> 
> With this instructions I can crash in like 3-5 minutes, with your patch
> it runs now for 50minutes now. Thanks.

Is this something going into the stable tree, or does it not affect 3.0,
3.2, 3.4 or 3.6?

-- Steve
