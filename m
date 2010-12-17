From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
	packets
Date: Fri, 17 Dec 2010 08:59:37 +0000
Message-ID: <20101217085937.GC6907@ff.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop> <20101216211744.GA2191@del.dom.local> <1292535039.2655.13.camel@edumazet-laptop> <20101216220838.GB2191@del.dom.local> <1292538363.2655.20.camel@edumazet-laptop> <20101216224237.GC2191@del.dom.local> <1292542305.2655.25.camel@edumazet-laptop> <20101217073015.GA6907@ff.dom.local> <1292573297.2655.42.camel@edumazet-laptop> <20101217083413.GB6907@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:63185 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114Ab0LQI7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 03:59:43 -0500
Received: by fxm18 with SMTP id 18so423808fxm.2
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 00:59:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101217083413.GB6907@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 08:34:13AM +0000, Jarek Poplawski wrote:
> On Fri, Dec 17, 2010 at 09:08:17AM +0100, Eric Dumazet wrote:
> > Care to suggest an alternative patch, because I am lost at this point ?
> 
> Just what I wrote earlier: consider one additional cloning in
> dev_queue_xmit_nit

Actually, it's enough to get time once and change it for all current
clones in the loop. 

Jarek P.
