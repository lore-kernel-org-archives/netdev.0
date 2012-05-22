From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Tue, 22 May 2012 15:18:30 -0400 (EDT)
Message-ID: <20120522.151830.2018953337014839778.davem@davemloft.net>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: b06378@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab2EVTUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 15:20:36 -0400
In-Reply-To: <1337677248-27792-1-git-send-email-b06378@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiajun Wu <b06378@freescale.com>
Date: Tue, 22 May 2012 17:00:48 +0800

> FCB(Frame Control Block) isn't the part of netdev hard header.
> Add FCB to hard_header_len will make GRO fail at MAC comparision stage.
> 
> Signed-off-by: Jiajun Wu <b06378@freescale.com>

Applied, thanks.

Someone needs to go through this driver when net-next opens up
and fix all of the indentation in this driver.
