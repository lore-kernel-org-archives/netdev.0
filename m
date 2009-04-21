From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Tue, 21 Apr 2009 01:52:35 -0700 (PDT)
Message-ID: <20090421.015235.23457775.davem@davemloft.net>
References: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jon.lin@vatics.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44205
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755745AbZDUIwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:52:43 -0400
In-Reply-To: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jon.lin@vatics.com>
Date: Mon, 20 Apr 2009 20:58:01 +0800

> While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
> In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before setting up the DMA buffer address. In this interval where RX was enabled and DMA buffer address is not yet set up, any incoming broadcast packet would be send to a strange physical address:
> 0x003e8800 which is the default value of DMA buffer address.
> Unfortunately, this address is used by Linux kernel. So kernel panics.
> This patch fix it by setting up DMA buffer address before RX enabled and everything is fine even under broadcast packets attack.
> 
> Signed-off-by: Jonathan Lin <jon.lin@vatics.com>

This patch does not apply, it was corrupted by your email client.

I even think it has MS-DOS style newlines in it :-(
