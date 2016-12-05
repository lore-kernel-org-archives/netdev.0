From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: usb: set error code when usb_alloc_urb fails
Date: Mon, 05 Dec 2016 13:27:48 -0500 (EST)
Message-ID: <20161205.132748.1851184102764779599.davem@davemloft.net>
References: <1480764288-5448-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: woojung.huh@microchip.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbcLES1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:27:51 -0500
In-Reply-To: <1480764288-5448-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>
Date: Sat,  3 Dec 2016 19:24:48 +0800

> In function lan78xx_probe(), variable ret takes the errno code on
> failures. However, when the call to usb_alloc_urb() fails, its value
> will keeps 0. 0 indicates success in the context, which is inconsistent
> with the execution result. This patch fixes the bug, assigning
> "-ENOMEM" to ret when usb_alloc_urb() returns a NULL pointer.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188771
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
