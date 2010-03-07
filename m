From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda-usb: add error handling and fix leak
Date: Sun, 07 Mar 2010 15:26:28 -0800 (PST)
Message-ID: <20100307.152628.35325677.davem@davemloft.net>
References: <20100307123542.GA6469@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, shemminger@vyatta.com, kaber@trash.net,
	tabe@mvista.com, julia@diku.dk, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751158Ab0CGX0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:26:09 -0500
In-Reply-To: <20100307123542.GA6469@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 7 Mar 2010 15:35:42 +0300

> If the call to kcalloc() fails then we should return -ENOMEM.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
