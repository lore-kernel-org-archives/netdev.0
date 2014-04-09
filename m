From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum issues
Date: Wed, 09 Apr 2014 14:42:06 -0400 (EDT)
Message-ID: <20140409.144206.149826397772279425.davem@davemloft.net>
References: <4ae24ae5c6ea45c399e7be03c69dc442@BY2PR03MB299.namprd03.prod.outlook.com>
 <20140409.143655.2112963679697366338.davem@davemloft.net>
 <b9662fd6593d462e83c5b88af75d5f2e@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <b9662fd6593d462e83c5b88af75d5f2e@BY2PR03MB299.namprd03.prod.outlook.com>
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
Date: Wed, 9 Apr 2014 18:39:57 +0000

> 
> 
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Wednesday, April 9, 2014 11:37 AM
>> To: KY Srinivasan
>> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>> jasowang@redhat.com
>> Subject: Re: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum
>> issues
>> 
>> From: KY Srinivasan <kys@microsoft.com>
>> Date: Wed, 9 Apr 2014 18:08:47 +0000
>> 
>> > Thanks Dave. I will COW the SKB before changing the checksum value. I
>> > do have a question though.  I looked at a bunch of hardware drivers
>> > and they modify the header information, specially checksum field and I
>> > could not see where they had COWed the skb. I was grepping for skb_cow
>> > in these drivers.
>> 
>> Look for skb_cow_head(), for example, the tg3.c driver uses this.
>> 
> Thank you. I will update this patch. Do you want me to resend the whole set or just
> this patch.

You never need to ask me this.

Always, when there is an update to any part of a series, re-submit the entire
series.
