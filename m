From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] bnx2: Check netif_running() in all
 ethtool operations.
Date: Thu, 09 Oct 2008 14:26:04 -0700 (PDT)
Message-ID: <20081009.142604.14627439.davem@davemloft.net>
References: <1223572568-1298-2-git-send-email-mchan@broadcom.com>
	<20081009.122210.120302203.davem@davemloft.net>
	<1223585940.23468.7.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752850AbYJIV02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:26:28 -0400
In-Reply-To: <1223585940.23468.7.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 09 Oct 2008 13:59:00 -0700

> 
> On Thu, 2008-10-09 at 12:22 -0700, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Thu,  9 Oct 2008 10:16:04 -0700
> > 
> > > We need to check netif_running() state in most ethtool operations
> > > and properly handle the !netif_running() state where the chip is
> > > in an uninitailzed state or low power state that may not accept
> > > any MMIO.
> > >
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > Signed-off-by: Benjamin Li <benli@broadcom.com>
> > > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > 
> > Applied, but I wonder if this will trip people up who invoke
> > ethtool to set a specific link setting before bringing the
> > device up?
> > 
> 
> ethtool -s is not affected by the patch and will continue to work
> whether the device is up or down.  The patch affects operations such as
> reading/writing NVRAM, restart autoneg, etc, that require the device to
> be up.

Thanks for the clarification.
