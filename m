From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: fix compilation
Date: Sat, 15 Sep 2007 19:32:22 -0400
Message-ID: <46EC6B86.3050405@garzik.org>
References: <20070912112456.GA15556@localhost.localdomain> <20070913152333.GA2381@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36797 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753047AbXIOXc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 19:32:29 -0400
In-Reply-To: <20070913152333.GA2381@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Vorontsov wrote:
> Currently qe_bd_t is used in the macro call -- dma_unmap_single,
> which is a no-op on PPC32, thus error is hidden today. Starting
> with 2.6.24, macro will be replaced by the empty static function,
> and erroneous use of qe_bd_t will trigger compilation error.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> Reposting this to include netdev in Cc.
> 
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied


