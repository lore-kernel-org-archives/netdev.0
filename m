From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Sat, 22 Dec 2007 17:17:07 -0800
Message-ID: <20071223011707.1798C2360C6@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <11983602953056-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: bjd@jooz.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:20418 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754146AbXLWBRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 20:17:11 -0500
In-Reply-To: <11983602953056-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Bjorge Dijkstra <bjd@jooz.net>
> Subject: [PATCH 6/8] [PATCH] Split up rndis_host.c
> Date: Sat, 22 Dec 2007 22:51:32 +0100
>
> Split up rndis_host.c into rndis_host.h and rndis_base.c and
> change Makefile accordingly. This is done so we can add extra
> source files to the rndis_host module later on.

I'm fine with splitting out a header file and the EXPORT_SYMBOL_GPL.
But why not just have a separate "rndis_wext" module?


> ---
>  drivers/net/usb/Makefile     |    1 +
>  drivers/net/usb/rndis_base.c |  548 ++++++++++++++++++++++++++++++
>  drivers/net/usb/rndis_host.c |  763 ------------------------------------------
>  drivers/net/usb/rndis_host.h |  256 ++++++++++++++
>  4 files changed, 805 insertions(+), 763 deletions(-)
>  create mode 100644 drivers/net/usb/rndis_base.c
>  delete mode 100644 drivers/net/usb/rndis_host.c
>  create mode 100644 drivers/net/usb/rndis_host.h
