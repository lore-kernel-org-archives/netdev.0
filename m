From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] chelsio: remove unused code for 1G boards
Date: Tue, 27 Feb 2007 04:32:17 -0500
Message-ID: <45E3FAA1.9050503@garzik.org>
References: <20070220235759.102686172@linux-foundation.org> <20070220235905.097058245@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47599 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161098AbXB0JcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:32:19 -0500
In-Reply-To: <20070220235905.097058245@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Some code for Chelsio 1G boards was put in the driver
> based on the vendor version (minus TOE). Well some of those board
> versions are only supported with TOE on the vendor driver, so additional
> dead code was added.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/chelsio/Makefile      |    4 
>  drivers/net/chelsio/ixf1010.c     |  505 --------------------------------------
>  drivers/net/chelsio/vsc8244.c     |  367 ---------------------------
>  drivers/net/chelsio/vsc8244_reg.h |  172 ------------
>  4 files changed, 1 insertion(+), 1047 deletions(-)

applied 1-3 to #upstream (2.6.22)


