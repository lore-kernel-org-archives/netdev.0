From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Thu, 07 Jun 2012 14:54:38 -0700 (PDT)
Message-ID: <20120607.145438.1351539405712214173.davem@davemloft.net>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: huajun.li.lee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932991Ab2FGVym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 17:54:42 -0400
In-Reply-To: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huajun Li <huajun.li.lee@gmail.com>
Date: Tue, 5 Jun 2012 22:12:17 +0800

> There prints endless "XactErr" error msg once switch my device to the
> configuration
>  which needs cdc_ether driver, the root cause is the interrupt endpoint halts.
> Maybe this is a common issue, so fix it by activating the endpoint
> once the error occurs.
> 
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>

A USB expert needs to review this as I lack the knowledge to adequately
go over this patch.
