From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] connector: export cn_already_initialized.
Date: Mon, 19 Jun 2006 23:43:52 -0700 (PDT)
Message-ID: <20060619.234352.107252623.davem@davemloft.net>
References: <20060506084045.GA16558@2ka.mipt.ru>
	<20060516.161406.23276754.davem@davemloft.net>
	<20060619053031.GA17406@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4792
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965094AbWFTGnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 02:43:51 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060619053031.GA17406@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 19 Jun 2006 09:30:35 +0400

> Attached patch declares connector init function as subsys_init()
> and returns -EAGAIN in case connector is not initialized yet.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Applied, but I had to fixup something by hand:

> @@ -433,7 +436,7 @@ static void cn_callback(void *data)
>  	up(&notify_lock);
>  }
>  
> -static int __init cn_init(void)
> +static int __devinit cn_init(void)

notify_lock is now a mutex.
