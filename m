From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "cxgb3: Check and handle the dma mapping errors"
Date: Thu, 15 Aug 2013 01:24:04 -0700 (PDT)
Message-ID: <20130815.012404.1180223951215075384.davem@davemloft.net>
References: <1376471941-2914-1-git-send-email-aik@ozlabs.ru>
	<520BA8E4.3010406@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aik@ozlabs.ru, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, santosh@chelsio.com,
	fenlason@redhat.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520BA8E4.3010406@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le ray <divy@chelsio.com>
Date: Wed, 14 Aug 2013 08:57:24 -0700

> On 08/14/2013 02:19 AM, Alexey Kardashevskiy wrote:
>> This reverts commit f83331bab149e29fa2c49cf102c0cd8c3f1ce9f9.
>>
>> As the tests PPC64 (powernv platform) show, IOMMU pages are leaking
>> when transferring big amount of small packets (<=64 bytes),
>> "ping -f" and waiting for 15 seconds is the simplest way to confirm
>> the bug.
>>
>> Cc: Linus Torvalds<torvalds@linux-foundation.org>
>> Cc: Santosh Rastapur<santosh@chelsio.com>
>> Cc: Jay Fenlason<fenlason@redhat.com>
>> Cc: David S. Miller<davem@davemloft.net>
>> Cc: Divy Le ray<divy@chelsio.com>
>> Signed-off-by: Alexey Kardashevskiy<aik@ozlabs.ru>
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks.
