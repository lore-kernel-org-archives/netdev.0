From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] arp_notify: unconditionally send gratuitous ARP for
 NETDEV_NOTIFY_PEERS.
Date: Tue, 15 Feb 2011 09:13:45 +0000
Message-ID: <1297761225.21980.3663.camel@zakaz.uk.xensource.com>
References: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
	 <20110214.174654.115944453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:52361 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753818Ab1BOJNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 04:13:47 -0500
In-Reply-To: <20110214.174654.115944453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-15 at 01:46 +0000, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Fri, 11 Feb 2011 17:44:16 +0000
> 
> > NETDEV_NOTIFY_PEER is an explicit request by the driver to send a link
> > notification while NETDEV_UP/NETDEV_CHANGEADDR generate link
> > notifications as a sort of side effect.
> > 
> > In the later cases the sysctl option is present because link
> > notification events can have undesired effects e.g. if the link is
> > flapping. I don't think this applies in the case of an explicit
> > request from a driver.
> > 
> > This patch makes NETDEV_NOTIFY_PEER unconditional, if preferred we
> > could add a new sysctl for this case which defaults to on.
> > 
> > This change causes Xen post-migration ARP notifications (which cause
> > switches to relearn their MAC tables etc) to be sent by default.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Ok, applied, thanks.

Thanks.

I nearly forgot -- the NETDEV_NOTIFY_PEER stuff was tagged for
stable/longterm backport (it appeared in 2.6.32.19 or so). I think this
change should likewise go back, what do you think?

Ian.


