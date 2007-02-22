From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][TCP] YeAH-TCP: algorithm implementation
Date: Thu, 22 Feb 2007 00:19:18 -0800 (PST)
Message-ID: <20070222.001918.55725416.davem@davemloft.net>
References: <45D97C62.5070406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco@net.infocom.uniroma1.it,
	andrea.baiocchi@uniroma1.it
To: angelo.castellani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751474AbXBVITT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:19:19 -0500
In-Reply-To: <45D97C62.5070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Date: Mon, 19 Feb 2007 11:30:58 +0100

> From: Angelo P. Castellani <angelo.castellani@gmail.con>
> 
> YeAH-TCP is a sender-side high-speed enabled TCP congestion control 
> algorithm, which uses a mixed loss/delay approach to compute the 
> congestion window. It's design goals target high efficiency, internal, 
> RTT and Reno fairness, resilience to link loss while keeping network 
> elements load as low as possible.
> 
> For further details look here:
>     http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
> 
> Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>

Applied to tcp-2.6 GIT, there were a lot of broken whitespace
issues in your patch, GIT makes mention of them quite happily
even without applying the patch, which I recommend you do in the
future so I don't have to fix up your patches.  The command I
use (best with 1.5.0 GIT) is:

	git apply --check --whitespace=error-all file.patch

Thanks.
