From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] macb: Fix section mismatch and shrink runtime footprint
Date: Fri, 01 Feb 2008 13:40:55 -0500
Message-ID: <47A367B7.1030305@garzik.org>
References: <1201781422-30181-1-git-send-email-hskinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Brownell <david-b@pacbell.net>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54898 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069AbYBASk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:40:57 -0500
In-Reply-To: <1201781422-30181-1-git-send-email-hskinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Haavard Skinnemoen wrote:
> macb devices are only found integrated on SoCs, so they can't be
> hotplugged. Thus, the probe() and exit() functions can be __init and
> __exit, respectively. By using platform_driver_probe() instead of
> platform_driver_register(), there won't be any references to the
> discarded probe() function after the driver has loaded.
> 
> This also fixes a section mismatch due to macb_probe(), defined as
> __devinit, calling macb_get_hwaddr, defined as __init.
> 
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
> ---
>  drivers/net/macb.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)

applied


