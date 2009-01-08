From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 8 Jan 2009 13:44:02 -0800
Message-ID: <20090108134402.6e88438f@extreme>
References: <20090108093430.0f966738@extreme>
	<20090108.112420.102641584.davem@davemloft.net>
	<20090108121220.789325a6@extreme>
	<20090108.125830.142298950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35995 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756627AbZAHVoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 16:44:05 -0500
In-Reply-To: <20090108.125830.142298950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jan 2009 12:58:30 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 8 Jan 2009 12:12:20 -0800
> 
> > What about this?
> > 
> > If it works (still testing), I'll submit it.
> 
> So what is your plan?
> 
> Make the routing daemons depend upon the non-default
> behavior in order to act correctly?
routing daemons don't deal with addresses directly now,
and getting them to do it would be painful.

> Or is it to gradually get people to use the non-default
> (via distribution sysctl settings etc.) and eventually
> make it the default?
No plan to ever change the default. Just ship with sysctl.conf
setting.

> I disagree with both plans, and with that the facility
> is basically useless.
> 
> We absolutely have to live with the behavior we have now,
> and for a long time if not forever.


