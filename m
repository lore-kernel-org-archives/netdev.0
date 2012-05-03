From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 4/7] mISDN: Make layer1 timer 3 value configurable
Date: Thu, 03 May 2012 17:08:30 -0400 (EDT)
Message-ID: <20120503.170830.1574473660496726919.davem@davemloft.net>
References: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
	<1336060052-27119-5-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928Ab2ECVIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 17:08:36 -0400
In-Reply-To: <1336060052-27119-5-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Thu,  3 May 2012 17:47:29 +0200

> @@ -372,6 +372,7 @@ clear_channelmap(u_int nr, u_char *map)
>  #define MISDN_CTRL_RX_OFF		0x0100
>  #define MISDN_CTRL_FILL_EMPTY		0x0200
>  #define MISDN_CTRL_GETPEER		0x0400
> +#define MISDN_CTRL_L1_TIMER3		0x0800
>  #define MISDN_CTRL_HW_FEATURES_OP	0x2000
>  #define MISDN_CTRL_HW_FEATURES		0x2001
>  #define MISDN_CTRL_HFC_OP		0x4000

This define is completely unused by this patch.

To say that I'm frustrated by this process would be an understatement.
