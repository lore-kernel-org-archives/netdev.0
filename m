From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] cxgb4vf: remove obsolete DECLARE_PCI_UNMAP_ADDR usage
Date: Thu, 08 Jul 2010 19:01:26 +0900
Message-ID: <20100708190126X.fujita.tomonori@lab.ntt.co.jp>
References: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:39398 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab0GHK0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 06:26:52 -0400
In-Reply-To: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jul 2010 18:52:37 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> We could use DEFINE_DMA_UNMAP_ADDR instead but using
> CONFIG_NEED_DMA_MAP_STATE is a simpler way to see if a platform does
> real DMA unmapping.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  drivers/net/cxgb4vf/sge.c |   14 +++++---------
>  1 files changed, 5 insertions(+), 9 deletions(-)

btw, I'm not sure that seeing if a platform does real DMA unmapping in
a driver is a good thing. But I suppose that we need to accept it if
this leads to big performance boost.

Both can be applied to net-next.
