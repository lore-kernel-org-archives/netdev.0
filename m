From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before
 re-submit URB
Date: Sun, 17 Jun 2012 16:30:17 -0700 (PDT)
Message-ID: <20120617.163017.1067800063889498786.davem@davemloft.net>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.leiming@gmail.com, stern@rowland.harvard.edu,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: huajun.li.lee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753Ab2FQXaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:30:18 -0400
In-Reply-To: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huajun Li <huajun.li.lee@gmail.com>
Date: Wed, 13 Jun 2012 20:50:31 +0800

> intr_complete() submits URB even the interrupt endpoint stalls.
> This patch will try to activate the endpoint once the exception
> occurs, and then re-submit the URB if the endpoint works again.
> 
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>

Review from USB experts would be appreciated.

Thanks.
