From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ieee802154: fix kconfig bool/tristate muckup
Date: Sat, 13 Jun 2009 23:37:37 -0700 (PDT)
Message-ID: <20090613.233737.178725457.davem@davemloft.net>
References: <4A31869B.3050901@oracle.com>
	<4A32DDC8.7060605@oracle.com>
	<20090613105753.GB14520@build.ossfans.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: slapin@ossfans.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090613105753.GB14520@build.ossfans.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Lapin <slapin@ossfans.org>
Date: Sat, 13 Jun 2009 14:57:54 +0400

> On Fri, Jun 12, 2009 at 03:59:20PM -0700, Randy Dunlap wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>> 
>> menuconfig IEEE802154_DRIVERS is a bool that depends on tristate IEEE802154.
>> If the IEEE802154 symbol is 'm', the bool becomes 'y'.
>> This allows tristate symbols under IEEE802154_DRIVERS to be configured as
>> 'y' and cause build problems.
>> Changing the menuconfig bool to a tristate fixes this.
>> 
>> drivers/built-in.o: In function `fake_scan_req':
>> fakehard.c:(.text+0x46d625): undefined reference to `ieee802154_nl_scan_confirm'
>> drivers/built-in.o: In function `fake_disassoc_req':
>> fakehard.c:(.text+0x46d66f): undefined reference to `ieee802154_nl_disassoc_confirm'
>> drivers/built-in.o: In function `fake_assoc_req':
>> fakehard.c:(.text+0x46d6be): undefined reference to `ieee802154_nl_assoc_confirm'
>> 
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc: linux-zigbee-devel@lists.sourceforge.net
>> Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> Cc: Sergey Lapin <slapin@ossfans.org>
> Ackedy-by: Sergey Lapin <slapin@ossfans.org>

It's "Acked-by:" :-)

Applied, thanks everyone.
