From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: accept bridge own MAC address as local
Date: Fri, 26 Aug 2011 09:42:40 -0700
Message-ID: <20110826094240.088cb76d@nehalam.ftrdhcpuser.net>
References: <20110812113024.GA8900@babylon>
	<20110826.122917.294108473242938413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ulrich.weber@sophos.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36469 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753849Ab1HZQmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 12:42:32 -0400
In-Reply-To: <20110826.122917.294108473242938413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2011 12:29:17 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Ulrich Weber <ulrich.weber@sophos.com>
> Date: Fri, 12 Aug 2011 13:30:24 +0200
> 
> > bridge: accept bridge own MAC address as local
> > if MAC address of bridge is manually set (BR_SET_MAC_ADDR). Otherwise
> > only MAC addresses of bridge members will work if manually set.
> > 
> > Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
> 
> As Stephen mentioned, the real bug is that we don't create a local
> FDB entry (and get rid of the old one) when the MAC address changes.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Another alternative is going back to restricting the mac address of
the bridge to be the same as one of the existing ports. This was how
it used to be, but some people wanted to set arbitrary addresses
(probably to deal with start up ordering issues).
