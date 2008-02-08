From: David Dillow <dave@thedillows.org>
Subject: Re: [patch 1/7] typhoon section fix
Date: Fri, 08 Feb 2008 08:59:10 -0500
Message-ID: <1202479150.4349.0.camel@obelisk.thedillows.org>
References: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	sam@ravnborg.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:47432 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962AbYBHN7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 08:59:13 -0500
In-Reply-To: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-02-08 at 03:11 -0800, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> gcc-3.4.4 on powerpc:
> 
> drivers/net/typhoon.c:137: error: version causes a section type conflict
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

> -static const char version[] __devinitdata =
> +static char version[] __devinitdata =
>      "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";

Wouldn't going to __devinitconst be better? I'll try to whip up a patch
and test-compile it.

