From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 10:28:16 -0700
Message-ID: <20100721102816.4bef5ada@nehalam>
References: <20100720141816.16f0a939@nehalam>
	<4C469808.5060308@redhat.com>
	<20100721150732.GR7497@gospo.rdu.redhat.com>
	<201007210934.27986.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Harald Hoyer <harald@redhat.com>,
	David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	sassmann@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gospo@redhat.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46392 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab0GUR2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 13:28:20 -0400
In-Reply-To: <201007210934.27986.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jul 2010 09:34:27 -0700
Casey Leedom <leedom@chelsio.com> wrote:

> | From: Andy Gospodarek <andy@greyhouse.net>
> | Date: Wednesday, July 21, 2010 08:07 am
> | 
> | Agreed.  The subtle difference between a locally assigned address that
> | is persistent and one that is random would be helpful.
> 
>   And just to point out that this case _does_ exist: the igb/igbvf drivers use 
> random_ether_addr() to generate a random, locally assigned MAC address for the 
> PCI-E SR-IOV Virtual Function MAC Addresses while the cxgb4/cxgb4vf drivers use 
> a persistent, non-random locally assigned MAC Addresses.
> 
>   Note that I am neither arguing for nor against the proposal.  I'm just 
> pointing out an existence case for the distinction.  And yes, bit 1 being set in 
> the first octet of a MAC address for locally assigned MAC Addresses is part of 
> the IEEE 802 specification just as bit 0 being set in the same octet indicates 
> that it's a multi-station address.

IMHO no local assigned address should be used by udev. The cxgb4 driver
should be using random value.

Does anyone have an example of locally assigned address that has persistence
so that udev could use it.
