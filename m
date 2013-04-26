From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Fri, 26 Apr 2013 07:14:26 -0700
Message-ID: <1366985666.8964.186.camel@edumazet-glaptop>
References: <1366786204.5977.10.camel@marge.simpson.net>
	 <1366853695.8964.120.camel@edumazet-glaptop>
	 <1366865490.4595.22.camel@marge.simpson.net>
	 <1366866233.8964.128.camel@edumazet-glaptop>
	 <20130426105030.GE20927@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:44634 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab3DZOO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 10:14:28 -0400
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

Thanks for testing !
