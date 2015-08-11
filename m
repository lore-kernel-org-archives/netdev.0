From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mkiss: Fix error handling in mkiss_open()
Date: Mon, 10 Aug 2015 21:10:55 -0700 (PDT)
Message-ID: <20150810.211055.763218711116840541.davem@davemloft.net>
References: <1439227363-6737-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zy900702@163.com
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbHKEK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:10:56 -0400
In-Reply-To: <1439227363-6737-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 10 Aug 2015 14:22:43 -0300

> If register_netdev() fails we are not propagating the error and
> we return success because ax_open() succeeded previously.
> 
> Fix this by checking the return value of ax_open() and 
> register_netdev() and propagate the error in case of failure.
> 
> Reported-by: RUC_Soft_Sec <zy900702@163.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
