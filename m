From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
 platform
Date: Sat, 12 Jan 2013 15:35:33 -0800 (PST)
Message-ID: <20130112.153533.1713284383322153346.davem@davemloft.net>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, alexey.orishko@stericsson.com,
	bjorn@mork.no, linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: cpuwolf@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab3ALXfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 18:35:34 -0500
In-Reply-To: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Shuai <cpuwolf@gmail.com>
Date: Sat, 12 Jan 2013 19:34:39 +0800

> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I
> introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in
> driver_info:data. so later on, if more such buggy devices are found,
> they could use same flag to handle.

Is it no able to do ARP or, the more likely case, does broadcast
not work at all?

If it's the latter, IFF_NOARP is just making over the real problem.

I'm not applying this, no hardware device should set IFF_NOARP.
You probably really want IFF_POINTOPOINT or similar.
