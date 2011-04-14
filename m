From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Clean up 'FLAG_POINTTOPOINT' and 'FLAG_MULTI_PACKET'
 overlaps in usbnet.h
Date: Thu, 14 Apr 2011 00:22:52 -0700 (PDT)
Message-ID: <20110414.002252.183040988.davem@davemloft.net>
References: <BANLkTinyWLjVRLKTZB09BZaH2o0gB0p8JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gottfried.haider@gmail.com, netdev@vger.kernel.org
To: huajun.li.lee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753299Ab1DNHX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 03:23:27 -0400
In-Reply-To: <BANLkTinyWLjVRLKTZB09BZaH2o0gB0p8JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huajun li <huajun.li.lee@gmail.com>
Date: Thu, 14 Apr 2011 09:43:32 +0800

> USB tethering does not work anymore since 2.6.39-rc2, but it's okay in
> -rc1. The root cause is the new added mask code 'FLAG_POINTTOPOINT'
> overlaps 'FLAG_MULTI_PACKET'  in  include/linux/usb/usbnet.h, this
> causes logic issue in  rx_process(). This patch cleans up the overlap.
> 
> Reported-and-Tested-by: Gottfried Haider <gottfried.haider@gmail.com>
> Signed-off-by:  Huajun Li <huajun.li.lee@gmail.com>

Applied, thanks.
