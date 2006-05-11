From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] dl2k: use explicit DMA_48BIT_MASK
Date: Thu, 11 May 2006 21:23:52 +0200
Message-ID: <20060511192352.GA18200@electric-eye.fr.zoreil.com>
References: <200605101812.k4AICpRo006555@dwalker1.mvista.com> <20060510185718.GA25334@electric-eye.fr.zoreil.com> <20060510235215.GC26617@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Walker <dwalker@mvista.com>, akpm@osdl.org,
	edward_peng@dlink.com.tw, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:21670 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750734AbWEKT1p
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 15:27:45 -0400
Content-Disposition: inline
In-Reply-To: <20060510235215.GC26617@us.ibm.com>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> DMA_*BIT_MASK is intended to be used in the DMA_API's checking of
> DMA controller's addressable memory, where as this is masking off the
> lower 48bits of a descriptor for its DMA address.  

Imho it's the specific reason why the DMA_*BIT_MASK applies here: the
code is already in dma-"tainted" land.

> I think a better solution (which I should've done when I pushed the
> original patch) would be a driver specific #define.  

$ find drivers -type f | xargs grep -i [^f]ffffffffffff[^f] | wc -l
12

No disagreement: it does not have a huge potential for code duplication.

-- 
Ueimor
