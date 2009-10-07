From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] ethoc: use system memory as buffer
Date: Wed, 07 Oct 2009 03:42:15 -0700 (PDT)
Message-ID: <20091007.034215.262567791.davem@davemloft.net>
References: <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-4-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758839AbZJGKmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:42:20 -0400
In-Reply-To: <1254735200-2718-4-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Chou <thomas@wytron.com.tw>
Date: Mon,  5 Oct 2009 17:33:20 +0800

> This patch enabled the ethoc to allocate system memory as buffer
> when there is no dedicated buffer memory.
> 
> Some hardware designs may not have dedicated buffer memory such as
> on chip or off chip SRAM. In this case, only one memory resource is
> supplied in the platform data instead of two. Then a DMA buffer can
> be allocated from system memory and used for the transfer.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
