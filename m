From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] net: netcp: remove call to
 netif_carrier_(on/off) for MAC to Phy interface
Date: Mon, 27 Apr 2015 13:23:18 -0400 (EDT)
Message-ID: <20150427.132318.64451627276298303.davem@davemloft.net>
References: <1429902101-2911-1-git-send-email-m-karicheri2@ti.com>
	<20150425.154856.1696991150241343700.davem@davemloft.net>
	<553E6CD7.9040409@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553E6CD7.9040409@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Mon, 27 Apr 2015 13:07:35 -0400

> On 04/25/2015 03:48 PM, David Miller wrote:
>> From: Murali Karicheri<m-karicheri2@ti.com>
>> Date: Fri, 24 Apr 2015 15:01:41 -0400
>>
>>> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
>>> is called which is not needed as Phy lib already updates the carrier
>>> status to net stack. This is needed only for other interface types
>>>
>>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>>
>> net-next is not open for submissions yet
> David,
> 
> Do I need to re-submit this patch when the net-next gets opened for
> this? This is essentially a bug fix and can be applied to current

If it's really a bug fix, then you shouldn't target it at net-next.

I'll never understand why people do things like this.
