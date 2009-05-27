From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] ixgbe: fix driver loading with
 unsupported module on 82598
Date: Tue, 26 May 2009 20:41:56 -0700 (PDT)
Message-ID: <20090526.204156.21027711.davem@davemloft.net>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
	<20090527005423.28535.1960.stgit@localhost.localdomain>
	<1243387737.16597.140.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756659AbZE0Dl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:41:56 -0400
In-Reply-To: <1243387737.16597.140.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 May 2009 02:28:57 +0100

> On Tue, 2009-05-26 at 17:54 -0700, Jeff Kirsher wrote:
>> From: Don Skidmore <donald.c.skidmore@intel.com>
>> 
>> We will now need to store the phy address which we do in the hw->phy
>> struct. Likewise we no longer need the mdio struct in hw->phy along
>> with the mdio functions ixgbe_mdio_write(read) which have been
>> removed.  ixgbe_ioctl was no longer used and referenced hw->phy.mdio
>> so it was also removed.
> 
> The ioctl is for the benefit of user-space!

Indeed, this is completely bogus.  I'm not applying this.

