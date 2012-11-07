From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/2] net: fec: reduce spin lock time in fec_ptp_adjfreq
Date: Wed, 7 Nov 2012 09:33:07 +0100
Message-ID: <20121107083307.GB2267@netboy.at.omicron.at>
References: <1352268889-16836-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	davem@davemloft.net, bhutchings@solarflare.com
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36492 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab2KGIdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 03:33:17 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so741656eek.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 00:33:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352268889-16836-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 07, 2012 at 02:14:49PM +0800, Frank Li wrote:
> move below calculate out of spin lock section
> 	diff = fep->cc.mult;
> 	diff *= ppb;
> 	diff = div_u64(diff, 1000000000ULL);
> 
> diff is local variable and not neccesary in spin lock
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
