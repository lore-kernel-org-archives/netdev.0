From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 13:17:48 -0700 (PDT)
Message-ID: <20100720.131748.51255156.davem@davemloft.net>
References: <1279627656.2110.13.camel@achroite.uk.solarflarecom.com>
	<4C45996B.3000003@redhat.com>
	<1279636194.2110.45.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sassmann@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gospo@redhat.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	leedom@chelsio.com, harald@redhat.com
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279636194.2110.45.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 20 Jul 2010 15:29:54 +0100

> On Tue, 2010-07-20 at 14:41 +0200, Stefan Assmann wrote:
>> Btw, the driver itself could also alter the flag. Then we'd have a well
>> defined way of setting a stable address.
> 
> The driver can't know whether an address assigned by the user is stable.

If userspace can somehow obtain a persistent address, it can kick
udev too.

I really don't see any real value provided by letting userspace mess
with this.  Because the permanence communicated in this value is from
the perspective of the kernel driver, it's really therefore about the
thing that's in ->perm_addr[] not what happens to be in ->addr[] right
now.
