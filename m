From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB2NET: SR9800: use %zu for dma_addr_t
Date: Wed, 12 Feb 2014 22:49:17 -0800
Message-ID: <1392274157.2214.27.camel@joe-AO722>
References: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>, netdev@vger.kernel.org,
	'Liu Junliang' <liujunliang_ljl@163.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0080.hostedemail.com ([216.40.44.80]:59653 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751417AbaBMGtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 01:49:21 -0500
In-Reply-To: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 15:31 +0900, Jingoo Han wrote:
> Use %zu for size_t in order to avoid the following build
> warning in printks.

Perhaps your subject is wrong.

This doesn't seem like a dma_addr_t.

If it is, it should be printed with
"%pad", &dma_addr_t
