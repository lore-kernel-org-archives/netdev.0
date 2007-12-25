From: David Miller <davem@davemloft.net>
Subject: Re: [SOCK] Avoid divides in sk_stream_pages() and
 __sk_stream_mem_reclaim()
Date: Mon, 24 Dec 2007 20:58:09 -0800 (PST)
Message-ID: <20071224.205809.56016548.davem@davemloft.net>
References: <20071221154508.97aef5d9.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751656AbXLYE6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 23:58:10 -0500
In-Reply-To: <20071221154508.97aef5d9.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 15:45:08 +0100

> [SOCK] Avoid divides in sk_stream_pages() and __sk_stream_mem_reclaim()
> 
> sk_forward_alloc being signed, we should take care of divides by
> SK_STREAM_MEM_QUANTUM we do in sk_stream_pages() and 
> __sk_stream_mem_reclaim()
> 
> This patchs introduces SK_STREAM_MEM_QUANTUM_SHIFT, defined
> as ilog2(SK_STREAM_MEM_QUANTUM), to be able to use right
> shifts instead of plain divides.
> 
> This should help compiler to choose right shifts instead of
> expensive divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
