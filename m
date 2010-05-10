From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH] cxgb3: fix linkup issue
Date: Mon, 10 May 2010 09:22:14 +0900
Message-ID: <4BE751B6.4010307@ct.jp.nec.com>
References: <4BCD0424.8030501@ct.jp.nec.com>	<4BCF4E0E.1080805@chelsio.com> <20100421.163458.239333058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:63180 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab0EJAZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 20:25:26 -0400
In-Reply-To: <20100421.163458.239333058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Divy Le Ray <divy@chelsio.com>
> Date: Wed, 21 Apr 2010 12:12:14 -0700
> 
>> Hiroshi Shimamoto wrote:
>>> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>>>
>>> I encountered an issue that not to link up on cxgb3 fabric.
>>> I bisected and found that this regression was introduced by
>>> 0f07c4ee8c800923ae7918c231532a9256233eed.
>>>
>>> Correct to pass phy_addr to cphy_init() at t3_xaui_direct_phy_prep().
>>>
>>> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>>>   
>> Sorry for the review delay, I just came back from some time off.
>> Acked-by: Divy Le Ray <divy@chelsio.com>
> 
> Applied to net-2.6, thanks.
> 

I think this patch should be in -stable, right?
I can see this issue on Fedora12 and Ubuntu10.04.

thanks,
Hiroshi
