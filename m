From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 1/1] dma-mapping: mark DMA_nBITS_MASK as deprecated fix
Date: Mon, 11 May 2009 11:36:07 +0900
Message-ID: <20090511113659U.fujita.tomonori@lab.ntt.co.jp>
References: <20090510085618D.fujita.tomonori@lab.ntt.co.jp>
	<1241939066-10178-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:34016 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757533AbZEKChD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2009 22:37:03 -0400
In-Reply-To: <1241939066-10178-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 May 2009 09:04:26 +0200
Jiri Slaby <jirislaby@gmail.com> wrote:

> Andrew, please fold into
> dma-mapping: mark DMA_nBITS_MASK as deprecated
> --
> 
> As Fujita correctly demurs, use more meaningful typedef name, so that we
> now see:
> warning: DMA_nnBIT_MASK is deprecated
> instead of
> warning: DMA_DEPRECATED is deprecated
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Yang Hongyang <yanghy@cn.fujitsu.com>
> Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Cc: Ingo Molnar <mingo@elte.hu>
> ---
>  include/linux/dma-mapping.h |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)

Acked-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>


But I think that you need to resend a version of this patch against
tip. We need this patch in linux-next to warn some new users of these
deprecated macros.

Thanks,
