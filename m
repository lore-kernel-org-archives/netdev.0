From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Wed, 6 May 2009 22:34:52 -0700
Message-ID: <20090506223452.65e545d8.akpm@linux-foundation.org>
References: <20090507141114M.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34921 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbZEGFiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 01:38:52 -0400
In-Reply-To: <20090507141114M.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 May 2009 14:14:16 +0900 FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> We replaced all DMA_nBIT_MASK macros with DMA_BIT_MASK(n) but why do
> we still keep DMA_nBIT_MASK macros in include/linux/dma-mapping.h?
> 
> As long as these macros exist, people use them. The current git has
> two users and linux-next have other users.
> 
> Is it better to remove DMA_nBIT_MASK macros completely now?

Yes, the plan is to remove them.

Doing so will break lots and lots of out-of-tree drivers, causing
people some grief.  Is there any way in which we can cause their use to
cause __deprecated warnings for a couple of months, to give people a
chance to migrate?
