From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: remove obsolete DECLARE_PCI_UNMAP_ADDR usage
Date: Thu, 08 Jul 2010 23:09:39 -0700 (PDT)
Message-ID: <20100708.230939.102558536.davem@davemloft.net>
References: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
	<20100708190126X.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, netdev@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752465Ab0GIGJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:09:24 -0400
In-Reply-To: <20100708190126X.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 08 Jul 2010 19:01:26 +0900

> On Thu, 8 Jul 2010 18:52:37 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
>> We could use DEFINE_DMA_UNMAP_ADDR instead but using
>> CONFIG_NEED_DMA_MAP_STATE is a simpler way to see if a platform does
>> real DMA unmapping.
>> 
>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>> ---
>>  drivers/net/cxgb4vf/sge.c |   14 +++++---------
>>  1 files changed, 5 insertions(+), 9 deletions(-)
> 
> btw, I'm not sure that seeing if a platform does real DMA unmapping in
> a driver is a good thing. But I suppose that we need to accept it if
> this leads to big performance boost.
> 
> Both can be applied to net-next.

I think the value of these "optimizations" is rapidly decreasing to
zero.  And I believe I've told the authors of either this driver or
another one that they should just remove this stuff completely.
