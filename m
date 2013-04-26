From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Fri, 26 Apr 2013 12:50:30 +0200
Message-ID: <20130426105030.GE20927@linutronix.de>
References: <1366786204.5977.10.camel@marge.simpson.net>
 <1366853695.8964.120.camel@edumazet-glaptop>
 <1366865490.4595.22.camel@marge.simpson.net>
 <1366866233.8964.128.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Mike Galbraith <bitbucket@online.de>,
	David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48248 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760012Ab3DZKue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 06:50:34 -0400
Content-Disposition: inline
In-Reply-To: <1366866233.8964.128.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2013-04-24 22:03:53 [-0700]:

>On Thu, 2013-04-25 at 06:51 +0200, Mike Galbraith wrote:
>
>> Thanks for the fix.  I'll apply it and beat on the box some more (g.p.).
>> Gripe only happened the one time during long workout day.
>
>To force it to happen, you need to invalidate the cached dst in socket.
>
>So presumably doing in the background some "ip ro ..." commands to
>add/delete routes.

With this instructions I can crash in like 3-5 minutes, with your patch
it runs now for 50minutes now. Thanks.

Sebastian
