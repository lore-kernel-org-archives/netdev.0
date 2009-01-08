From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/42] appletalk: convert aarp to net_device_ops
Date: Wed, 07 Jan 2009 20:39:47 -0800 (PST)
Message-ID: <20090107.203947.127405186.davem@davemloft.net>
References: <20090107003345.513599743@vyatta.com>
	<20090107.172155.115059815.davem@davemloft.net>
	<1231384172.1739.31.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, acme@ghostprotcols.net,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45226
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752117AbZAHEjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 23:39:46 -0500
In-Reply-To: <1231384172.1739.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 07 Jan 2009 19:09:32 -0800

> On Wed, 2009-01-07 at 17:21 -0800, David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > Applied.
> 
> Was it necessary to preface ndo_ to all the netdev_ops members?
> It's a bit hungarian compared to most all kernel sources.

Yes, so that it is easily grep'able, I explicitly asked
Stephen Hemminger to make it this way.
