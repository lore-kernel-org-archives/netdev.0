From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 7 Jul 2008 10:05:56 -0700
Message-ID: <20080707100556.6a3dd3d7@extreme>
References: <20080706130801.6bc36cf7@infradead.org>
	<20080706.155318.46569612.davem@davemloft.net>
	<20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
	<48717714.9060800@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arjan@infradead.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:34937 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019AbYGGRGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 13:06:03 -0400
In-Reply-To: <48717714.9060800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jul 2008 21:53:24 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Sun, 6 Jul 2008 18:08:42 -0700
> > 
> >> For consistency each call through ethtool_ops should
> >> be holding rtnl mutex. And since dev_watchdog is a timer routine,
> >> it is not safe to acquire a mutex there.
> > 
> > I think "get driver info", which does nothing but copy strings out of
> > the driver software state, is a safe exception to these strict locking
> > rules.
> > 
> > Don't you think? :-)
> 
> Indeed...
> 

It is save exception, but documentation needed?
