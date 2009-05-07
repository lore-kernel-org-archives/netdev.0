From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Thu, 7 May 2009 13:18:46 +0200
Message-ID: <20090507111846.GI28398@elte.hu>
References: <20090507141114M.fujita.tomonori@lab.ntt.co.jp> <4A0272C7.3060409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50207 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbZEGLTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 07:19:14 -0400
Content-Disposition: inline
In-Reply-To: <4A0272C7.3060409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Yang Hongyang <yanghy@cn.fujitsu.com> wrote:

> FUJITA Tomonori wrote:
> > We replaced all DMA_nBIT_MASK macros with DMA_BIT_MASK(n) but why do
> > we still keep DMA_nBIT_MASK macros in include/linux/dma-mapping.h?
> > 
> > As long as these macros exist, people use them. The current git has
> > two users and linux-next have other users.
> > 
> > Is it better to remove DMA_nBIT_MASK macros completely now?

Can you see a way to emit build warnings? If yes then that might be 
a better solution instead of breaking in-the-pipeline code. We 
missed the upstream window of removing the facilities altogether, we 
could certainly do that in the next merge window though.

> CC:ingo
> 
> I have no objections,actually I used to remove all these defines in my
> first commit of these patch series,but got suggestions that keep these
> defines one more circle.Maybe it's time to remove these defines now or
> to remove at the end of this circle?
> 
> Reviewed-by:yanghy@cn.fujitsu.com

Thanks!

	Ingo
