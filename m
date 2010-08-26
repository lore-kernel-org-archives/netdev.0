From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qlge: reset the chip before freeing the buffers
Date: Thu, 26 Aug 2010 13:19:06 -0700
Message-ID: <20100826201906.GD19906@linux-ox1b.qlogic.org>
References: <1282847278-23416-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ying Ping Lok <ying.lok@qlogic.com>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:52640 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753383Ab0HZUaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 16:30:09 -0400
Content-Disposition: inline
In-Reply-To: <1282847278-23416-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno,
looks good.
Thanks

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>




On Thu, Aug 26, 2010 at 11:27:58AM -0700, leitao@linux.vnet.ibm.com wrote:
> Qlge is freeing the buffers before stopping the card DMA, and
> this can cause some severe error, as a EEH event on PPC.
> 
> This patch just stop the card and then free the resources.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
