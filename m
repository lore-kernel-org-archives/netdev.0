From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: fix linkup issue
Date: Wed, 21 Apr 2010 16:34:58 -0700 (PDT)
Message-ID: <20100421.163458.239333058.davem@davemloft.net>
References: <4BCD0424.8030501@ct.jp.nec.com>
	<4BCF4E0E.1080805@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: h-shimamoto@ct.jp.nec.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BCF4E0E.1080805@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 21 Apr 2010 12:12:14 -0700

> Hiroshi Shimamoto wrote:
>> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>>
>> I encountered an issue that not to link up on cxgb3 fabric.
>> I bisected and found that this regression was introduced by
>> 0f07c4ee8c800923ae7918c231532a9256233eed.
>>
>> Correct to pass phy_addr to cphy_init() at t3_xaui_direct_phy_prep().
>>
>> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>>   
> 
> Sorry for the review delay, I just came back from some time off.
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied to net-2.6, thanks.
