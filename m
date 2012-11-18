From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] sis900: fix sis900_set_mode call parameters.
Date: Sun, 18 Nov 2012 18:28:44 -0500 (EST)
Message-ID: <20121118.182844.1217736137926302548.davem@davemloft.net>
References: <20121118224150.GA6755@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, medhefgo@web.de, venza@brownhat.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663Ab2KRX2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 18:28:49 -0500
In-Reply-To: <20121118224150.GA6755@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 18 Nov 2012 23:41:50 +0100

> Leftover of 57d6d456cfb89264f87d24f52640ede23fdf12bd ("sis900: stop
> using net_device.{base_addr, irq} and convert to __iomem.").
> 
> It is needed for suspend / resume to work.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Jan Janssen <medhefgo@web.de>
> Cc: Daniele Venzano <venza@brownhat.org>

Ouch, applied, thanks!
