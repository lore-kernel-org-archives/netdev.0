From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/9] atm/firestream: handle thrown error
Date: Fri, 20 Oct 2006 19:51:08 -0700 (PDT)
Message-ID: <20061020.195108.133288189.davem@davemloft.net>
References: <200610202143.k9KLhEFH003795@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63460
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992808AbWJUCvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 22:51:07 -0400
To: akpm@osdl.org
In-Reply-To: <200610202143.k9KLhEFH003795@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 20 Oct 2006 14:43:14 -0700

> From: Jeff Garzik <jeff@garzik.org>
> 
> gcc emits the following warning:
> 
> drivers/atm/firestream.c: In function $,1rx(Bfs_open$,1ry(B:
> drivers/atm/firestream.c:870: warning: $,1rx(Btmc0$,1ry(B may be used uninitialized in this function
> 
> This indicates a real bug.  We should check make_rate() return value for
> potential errors.
> 
> Signed-off-by: Jeff Garzik <jeff@garzik.org>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
