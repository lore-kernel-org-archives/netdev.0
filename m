From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 11:39:06 -0700 (PDT)
Message-ID: <20100721.113906.102700682.davem@davemloft.net>
References: <20100721102816.4bef5ada@nehalam>
	<20100721.103249.107094774.davem@davemloft.net>
	<201007211129.48288.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, andy@greyhouse.net, harald@redhat.com,
	bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com
To: leedom@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007211129.48288.leedom@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Casey Leedom <leedom@chelsio.com>
Date: Wed, 21 Jul 2010 11:29:47 -0700

>   Another option might be to have a new Net Device Operations call to ask the 
> adapter for a Unique Key.  This could be formed for most devices via a tuple of 
> the {PCI Vendor ID, PCI Device ID, Adapter Serial Number, Port Number, [and if 
> applicable] Adapter Function ID}.  Of course this could be a fairly long string 
> ... :-)

If a unique key were available, it could be used to generate a persistent
MAC address.

And this sort of means that these drivers could use bits of the
device's geographic ID the construct persistent MAC addresses, but
only if done in a MAC namespace that could be guarenteed unique on the
local system.
