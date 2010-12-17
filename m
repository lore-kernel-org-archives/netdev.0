From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] ipv6: remove duplicate neigh_ifdown
Date: Fri, 17 Dec 2010 10:01:01 -0800
Message-ID: <20101217100101.5e6e6708@nehalam>
References: <20101216175152.6767d0a7@nehalam>
	<20101216194254.0f7c7e7b@nehalam>
	<20101217.094916.193712831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35291 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755612Ab0LQSBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 13:01:09 -0500
In-Reply-To: <20101217.094916.193712831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Dec 2010 09:49:16 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 16 Dec 2010 19:42:54 -0800
> 
> > When device is being set to down, neigh_ifdown was being called
> > twice. Once from addrconf notifier and once from ndisc notifier.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> I'll give you a cookie if you can show me how this patch applies to
> net-next-2.6 cleanly. :-)
> 
> It only matches the code in net-2.6 which has changed non-trivially in
> net-next-2.6
> 
> If you worked against net-2.6 and thought "I can't think of anything
> that could have changed in net-next-2.6 in this area", that's not
> an appropriate way to operate and submit patches.
> 
> Please don't be so careless, thanks.

Ok. It followed my last patch that did the rt6_ifdown only
if not loopback. Since you accepted that, I sent the next one.



-- 
