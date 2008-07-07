From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 7 Jul 2008 16:44:25 -0700
Message-ID: <20080707164425.0af7087b@extreme>
References: <20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
	<adafxqlxqi5.fsf@cisco.com>
	<20080707.155723.48071035.davem@davemloft.net>
	<adazlotwalk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arjan@infradead.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54119 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605AbYGGXob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 19:44:31 -0400
In-Reply-To: <adazlotwalk.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Jul 2008 16:14:31 -0700
Roland Dreier <rdreier@cisco.com> wrote:

>  > I doubt it uses the RTNL semaphore elsewhere to protect
>  > against this path, which is the only protection these
>  > calls currently have.
> 
> As far as I can tell from reading the code, the only places in cxgb3
> that use t3_read_flash() are in the netdevice's open and ioctl methods,
> and the ethtool get_drvinfo method.  So as far as I can tell the current
> code is fine as long as rtnl is held across get_drvinfo.
> 
>  > Please don't bring up scarecrows, this looks like simply
>  > a bug which already exists.
> 
> I don't even know how to take this.  "Please don't review our changes"??
> "Please don't report bugs"??
> 
>  - R.

Long term, it would be good to move the driver name into device struct?
Easier and could work for all those random other drivers :-)
