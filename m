From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH for 2.6.25 1/2] [NET] ucc_geth: fix module removal
Date: Fri, 01 Feb 2008 13:40:34 -0500
Message-ID: <47A367A2.10706@pobox.com>
References: <20080201132248.GA1790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54884 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755026AbYBASko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:40:44 -0500
In-Reply-To: <20080201132248.GA1790@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> - uccf should be set to NULL to not double-free memory on
>   subsequent calls;
> - ind_hash_q and group_hash_q lists should be initialized in the
>   probe() function, instead of struct_init() (called by open()),
>   otherwise there will be an oops if ucc_geth_driver removed
>   prior 'ifconfig ethX up';
> - add unregister_netdev();
> - reorder geth_remove() steps.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> Hi Li,
> 
> You kinda promised that these two patches would hit 2.6.25... ;-)
> 
> I've rebased the patches so they apply cleanly on the current tree.
> 
> Thanks,
> 
>  drivers/net/ucc_geth.c |   17 ++++++++++-------
>  1 files changed, 10 insertions(+), 7 deletions(-)

applied 1-2


