From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgb: remove unused variable
Date: Tue, 25 Mar 2008 23:18:50 -0400
Message-ID: <47E9C09A.3070506@garzik.org>
References: <20080317171227.19970.89233.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59870 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbYCZDSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:18:53 -0400
In-Reply-To: <20080317171227.19970.89233.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The variable num_group_tail_writes is initialized but never used otherwise.
> 
> The semantic patch that makes this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> type T;
> identifier i;
> constant C;
> @@
> 
> (
> extern T i;
> |
> - T i;
>   <+... when != i
> - i = C;
>   ...+>
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)

applied


