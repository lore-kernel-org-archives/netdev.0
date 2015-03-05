From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tg3: use napi_complete_done()
Date: Thu, 05 Mar 2015 15:52:29 -0800
Message-ID: <1425599549.5130.268.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425595653.15992.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:46369 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbbCEXwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 18:52:31 -0500
Received: by iery20 with SMTP id y20so27853862ier.13
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 15:52:30 -0800 (PST)
In-Reply-To: <1425595653.15992.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-05 at 14:47 -0800, Michael Chan wrote:

> There is another napi_complete() call when we detect tx errors.  I guess
> we can leave that one unconverted as that code path is very rare.
> Thanks.


Absolutely. I didn't want to mess the recovery thing, already
quite risky ;)

> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Thanks !
