From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum
 issues
Date: Wed, 9 Apr 2014 18:39:57 +0000
Message-ID: <b9662fd6593d462e83c5b88af75d5f2e@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1396986371-12137-4-git-send-email-kys@microsoft.com>
	<20140409.130111.1002891296248446198.davem@davemloft.net>
	<4ae24ae5c6ea45c399e7be03c69dc442@BY2PR03MB299.namprd03.prod.outlook.com>
 <20140409.143655.2112963679697366338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140409.143655.2112963679697366338.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, April 9, 2014 11:37 AM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH net 3/3] Drivers: net: hyperv: Address UDP checksum
> issues
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Wed, 9 Apr 2014 18:08:47 +0000
> 
> > Thanks Dave. I will COW the SKB before changing the checksum value. I
> > do have a question though.  I looked at a bunch of hardware drivers
> > and they modify the header information, specially checksum field and I
> > could not see where they had COWed the skb. I was grepping for skb_cow
> > in these drivers.
> 
> Look for skb_cow_head(), for example, the tg3.c driver uses this.
> 
Thank you. I will update this patch. Do you want me to resend the whole set or just
this patch.

K. Y
