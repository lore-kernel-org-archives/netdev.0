From: Thomas Graf <tgraf@suug.ch>
Subject: Re: some weird corruption in net-2.6.24
Date: Mon, 3 Sep 2007 11:57:19 +0200
Message-ID: <20070903095719.GE18480@postel.suug.ch>
References: <20070830.223910.70218812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35440 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbXICJ46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 05:56:58 -0400
Content-Disposition: inline
In-Reply-To: <20070830.223910.70218812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-08-30 22:39
> 
> Every so often some piece of userland dies, and often it's
> bad enough that my desktop session logs out.
> 
> I've been trying to find some clues and it seems to happen
> about as often as openswan rekeys my VPN, so one suspect
> area is the netlink cleanups to xfrm_user.
> 
> I plan to do some auditing of those changes looking for
> errors, but if someone can beat me to it... :-)

I've been trying to reproduce this, what happens on my system
is that when the ISAKMP SA lifetime is exceeded the rekeying
fails and my connection dies. I can reproduce this back to
2.6.22 and it doesn't seem related to my recent xfrm_user work.
It looks like this behaviour is hiding the bug you are seeing.
