From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum issues
Date: Wed, 09 Apr 2014 14:36:55 -0400 (EDT)
Message-ID: <20140409.143655.2112963679697366338.davem@davemloft.net>
References: <1396986371-12137-4-git-send-email-kys@microsoft.com>
 <20140409.130111.1002891296248446198.davem@davemloft.net>
 <4ae24ae5c6ea45c399e7be03c69dc442@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <4ae24ae5c6ea45c399e7be03c69dc442@BY2PR03MB299.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: KY Srinivasan <kys@microsoft.com>
Date: Wed, 9 Apr 2014 18:08:47 +0000

> Thanks Dave. I will COW the SKB before changing the checksum
> value. I do have a question though.  I looked at a bunch of hardware
> drivers and they modify the header information, specially checksum
> field and I could not see where they had COWed the skb. I was
> grepping for skb_cow in these drivers.

Look for skb_cow_head(), for example, the tg3.c driver uses this.
