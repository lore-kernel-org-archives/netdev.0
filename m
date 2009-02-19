From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 00/12]Next:Get rid of all the old micro DMA_XXBIT_MASK
	and use DMA_BIT_MASK(n) instead
Date: Thu, 19 Feb 2009 14:49:32 +0800
Message-ID: <20090219064932.GB3296@hack.private>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:9537 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbZBSGtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 01:49:25 -0500
Content-Disposition: inline
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2009 at 02:35:52PM +0800, Yang Hongyang wrote:
>Replace all DMA_XXBIT_MASK micro with new DMA_BIT_MASK(n) micro
>
>01:Replace all DMA_64BIT_MASK micro with DMA_BIT_MASK(64)
>02:Replace all DMA_48BIT_MASK micro with DMA_BIT_MASK(48)
>03:Replace all DMA_40BIT_MASK micro with DMA_BIT_MASK(40)
>04:Replace all DMA_39BIT_MASK micro with DMA_BIT_MASK(39)
>05:Replace all DMA_35BIT_MASK micro with DMA_BIT_MASK(35)
>06:Replace all DMA_32BIT_MASK micro with DMA_BIT_MASK(32)
>07:Replace all DMA_31BIT_MASK micro with DMA_BIT_MASK(31)
>08:Replace all DMA_30BIT_MASK micro with DMA_BIT_MASK(30)
>09:Replace all DMA_28BIT_MASK micro with DMA_BIT_MASK(28)
>10:Replace all DMA_24BIT_MASK micro with DMA_BIT_MASK(24)
>11:Remove defines of DMA_XXBIT_MASK micro
>12:Update related documentations

s/micro/macro/


-- 
"Against stupidity, the gods themselves, contend in vain."

