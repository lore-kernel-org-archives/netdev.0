From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 07 Jul 2008 16:14:31 -0700
Message-ID: <adazlotwalk.fsf@cisco.com>
References: <20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
	<adafxqlxqi5.fsf@cisco.com>
	<20080707.155723.48071035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, arjan@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:39083 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbYGGXOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 19:14:33 -0400
In-Reply-To: <20080707.155723.48071035.davem@davemloft.net> (David Miller's
	message of "Mon, 07 Jul 2008 15:57:23 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I doubt it uses the RTNL semaphore elsewhere to protect
 > against this path, which is the only protection these
 > calls currently have.

As far as I can tell from reading the code, the only places in cxgb3
that use t3_read_flash() are in the netdevice's open and ioctl methods,
and the ethtool get_drvinfo method.  So as far as I can tell the current
code is fine as long as rtnl is held across get_drvinfo.

 > Please don't bring up scarecrows, this looks like simply
 > a bug which already exists.

I don't even know how to take this.  "Please don't review our changes"??
"Please don't report bugs"??

 - R.
