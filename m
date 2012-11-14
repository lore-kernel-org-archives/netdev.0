From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 17:50:50 -0800
Message-ID: <1352857850.6276.71.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20121113.181600.667479923208656972.davem@davemloft.net>
 <1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20121113.202408.79469396824848499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2097 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123Ab2KNBvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:51:05 -0500
In-Reply-To: <20121113.202408.79469396824848499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 20:24 -0500, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 13 Nov 2012 15:40:29 -0800
> 
> > I suppose we can just put the SAN MAC into the real netdev->dev_addr so
> > that the VLAN will automatically get it.  But this doesn't seem very
> > nice as we would be pretending to have a normal MAC address (for
> > networking) in this SAN device.  The networking MAC address is in a
> > different PCI function.
> 
> I certainly would prefer if you took that approach.  At least in that
> way the addressing of the netdev objects would appear more consistent.
> 
Ok.  To be more complete, I think we need to add a flag or something to
such a netdev to indicate that it is a SAN device only.  What's your
opinion on that?
