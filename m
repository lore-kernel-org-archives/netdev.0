From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH 11/15] sfc: use IS_ENABLED() instead of checking for
 built-in or module
Date: Mon, 12 Sep 2016 15:31:35 +0100
Message-ID: <1c515ec1-604a-f685-fced-52b96eeeeb78@solarflare.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
 <1473689026-6983-12-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Edward Cree <ecree@solarflare.com>,
        "Solarflare linux maintainers" <linux-net-drivers@solarflare.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:2510 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754160AbcILObr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:31:47 -0400
In-Reply-To: <1473689026-6983-12-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/16 15:03, Javier Martinez Canillas wrote:
> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
> 
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Acked-by: Bert Kenward <bkenward@solarflare.com>

Thanks,

Bert.
