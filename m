From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: fix NULL pointer dereference on memory
 allocation failure
Date: Mon, 25 Jul 2016 11:25:15 -0700 (PDT)
Message-ID: <20160725.112515.1809603371800148887.davem@davemloft.net>
References: <1469252630-14008-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469252630-14008-1-git-send-email-vegard.nossum@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Sat, 23 Jul 2016 07:43:50 +0200

> I ran into this:
 ...
> The problem is that irda_open_tsap() can fail and leave self->tsap = NULL,
> and then irttp_connect_request() almost immediately dereferences it.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied and queued up for -stable, thanks.
