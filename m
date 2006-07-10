From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Tue, 11 Jul 2006 00:21:53 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0607110021240.5420@yvahk01.tjqt.qr>
References: <20060710152032.GA8540@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yi.zhu@intel.com, jketreno@linux.intel.com,
	Netdev list <netdev@vger.kernel.org>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux01.gwdg.de ([134.76.13.21]:16816 "EHLO linux01.gwdg.de")
	by vger.kernel.org with ESMTP id S965276AbWGJWX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 18:23:58 -0400
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20060710152032.GA8540@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Is there better way of creating N/m config option?

> config IPW2100
> 	tristate "Intel PRO/Wireless 2100 Network Connection"
>-	depends on NET_RADIO && PCI
>+	depends on NET_RADIO && PCI && MODULE_ONLY

"depends on NET_RADIO && PCI && m"


Jan Engelhardt
-- 
