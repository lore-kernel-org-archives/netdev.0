From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: gen_estimator: more fuel for Jarek and Changli
Date: Wed, 9 Jun 2010 06:51:35 +0000
Message-ID: <20100609065134.GA6679@ff.dom.local>
References: <20100608121546.GA9392@ff.dom.local> <1276000052.2475.307.camel@edumazet-laptop> <20100608124052.GB9392@ff.dom.local> <4C0E9A2E.9080109@gmail.com> <1276026329.2439.2.camel@edumazet-laptop> <20100608202405.GA3496@del.dom.local> <1276030354.2439.8.camel@edumazet-laptop> <1276063997.2439.650.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47635 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab0FIGvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 02:51:42 -0400
Received: by fxm8 with SMTP id 8so3359097fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 23:51:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276063997.2439.650.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 08:13:17AM +0200, Eric Dumazet wrote:
> 
> With un-modified kernel, I ran following scripts on my machine

Why not modified with your other patch quite obviously needed by
rateest?:

> [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
> 
> gen_kill_estimator() / gen_new_estimator() is not always called with
> RTNL held.

Btw, I agree with Changli that adding RTNL to rateest (if possible),
and doing the RTNL replacement later, seems more proper.

Jarek P.
