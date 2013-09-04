From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Don't turn off led on 5719 serdes port 0
Date: Tue, 03 Sep 2013 22:24:34 -0400 (EDT)
Message-ID: <20130903.222434.1310610718775011320.davem@davemloft.net>
References: <1377907296-25737-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583Ab3IDCYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:24:36 -0400
In-Reply-To: <1377907296-25737-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Fri, 30 Aug 2013 17:01:36 -0700

> From: Nithin Sujir <nsujir@broadcom.com>
> 
> Turning off led on port 0 of the 5719 serdes causes all other ports to
> lose power and stop functioning. Add tg3_phy_led_bug() function to check
> for this condition. We use a switch() in tg3_phy_led_bug() for
> consistency with the tg3_phy_power_bug() function.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable, thanks.
