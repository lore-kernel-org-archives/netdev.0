From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 11:12:59 +0200
Message-ID: <20140814091259.GA11727@netboy>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814084251.GC7555@netboy>
 <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:55041 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaHNJNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:13:07 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so801654wes.22
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 02:13:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 09:02:07AM +0000, fugang.duan@freescale.com wrote:
> 
> I know your means. Even if cancel the time_keep work, ptp timer still is running and continutious.
> The time_keep work just to avoid timer overrun because FEC just support 32bit counter.

Right, so the time_keep must continue when the clock is running. It
does not depend on whether time stamping is enabled.

> And, you said "return an error", I don't know your mean.
> In addition, when clock is disabled, FEC ptp counter don't run any more.

You can return an error from your 'gettime' method.

Thanks,
Richard
