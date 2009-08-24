From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Sun, 23 Aug 2009 22:57:43 -0700 (PDT)
Message-ID: <20090823.225743.135339409.davem@davemloft.net>
References: <a4423d670908231055o2bb65fe0le2c33fe94b660b38@mail.gmail.com>
	<20090823.184924.26788268.davem@davemloft.net>
	<20090824043831.GA2473@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.y.miao@gmail.com, linux-arm-kernel@lists.arm.linux.org.uk,
	linux@arm.linux.org.uk, samuel@sortiz.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, marek.vasut@gmail.com
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751545AbZHXF5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 01:57:30 -0400
In-Reply-To: <20090824043831.GA2473@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Mon, 24 Aug 2009 08:38:31 +0400

> Subject: [PATCH] pxaficp-ir - remove incorrect net_device_ops
> 
> This patch fixes broken pxaficp-ir. The problem was in incorrect
> net_device_ops being specified which prevented the driver from
> operating. The symptoms were:
>  - failing ifconfig for IrLAN, resulting in
> 	SIOCSIFFLAGS: Cannot assign requested address
>  - irattach working for IrCOMM, but the port stayed disabled
> 
> Moreover this patch corrects missing sysfs device link.
> 
> Signed-off-by: Marek Vasut <marek.vasut@gmail.com>

Applied, thanks.
