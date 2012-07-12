From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 7/7] be2net: Enable RSS UDP hashing for Lancer
 and Skyhawk
Date: Thu, 12 Jul 2012 23:37:01 +0100
Message-ID: <1342132621.2662.64.camel@bwh-desktop.uk.solarflarecom.com>
References: <58046138-832a-49a2-84a8-fa682a74162e@exht1.ad.emulex.com>
	 <1342102215.3265.8263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48410 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759425Ab2GLWhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 18:37:05 -0400
In-Reply-To: <1342102215.3265.8263.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 16:10 +0200, Eric Dumazet wrote:
> On Thu, 2012-07-12 at 19:27 +0530, Padmanabh Ratnakar wrote:
> > Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> > ---
> >  drivers/net/ethernet/emulex/benet/be.h      |    3 +++
> >  drivers/net/ethernet/emulex/benet/be_cmds.c |    7 +++++++
> >  drivers/net/ethernet/emulex/benet/be_cmds.h |    2 ++
> >  3 files changed, 12 insertions(+), 0 deletions(-)
> 
> It would be nice to add a bit of documentation on this, and what
> components are used from the tuple (dst addr, src addr, dst port, src
> port)

That's what ETHTOOL_GRXFH is for.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
