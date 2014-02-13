From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] USB2NET: SR9800: use %zu for dma_addr_t
Date: Thu, 13 Feb 2014 16:07:52 +0900
Message-ID: <000001cf288a$4fb2ceb0$ef186c10$%han@samsung.com>
References: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
 <1392274157.2214.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>, netdev@vger.kernel.org,
	'Liu Junliang' <liujunliang_ljl@163.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Joe Perches' <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:35256 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbaBMHHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 02:07:54 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N0X00AH4AH5M370@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Feb 2014 16:07:53 +0900 (KST)
In-reply-to: <1392274157.2214.27.camel@joe-AO722>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, February 13, 2014 3:49 PM, Joe Perches wrote:
> On Thu, 2014-02-13 at 15:31 +0900, Jingoo Han wrote:
> > Use %zu for size_t in order to avoid the following build
> > warning in printks.
> 
> Perhaps your subject is wrong.
> 
> This doesn't seem like a dma_addr_t.

Oh, it is my mistake! :-(
The subject should be the following.
  [PATCH] USB2NET: SR9800: use %zu for size_t

I will send v2 patch, soon.
Thank you for your comment. :-)

Best regards,
Jingoo Han

> 
> If it is, it should be printed with
> "%pad", &dma_addr_t
