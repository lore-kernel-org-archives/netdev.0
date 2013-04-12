From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: put tx to napi poll function to
 fix dead lock
Date: Fri, 12 Apr 2013 10:38:24 -0300
Message-ID: <CAOMZO5C9ZX_SygEdMdcGXbH8=gLKn0igOMkZ8vGP3HNzD+fvxA@mail.gmail.com>
References: <1362368065-5809-1-git-send-email-Frank.Li@freescale.com>
	<20130320114824.GA6088@S2101-09.ap.freescale.net>
	<CAOMZO5B-ipzyb2uiLW12fFd3PD3JfLS8R0YLM5vtLgFNz8abUw@mail.gmail.com>
	<20130324143525.GI6281@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>, B38611@freescale.com,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, lznuaa@gmail.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:42761 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab3DLNiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:38:25 -0400
Received: by mail-vb0-f52.google.com with SMTP id w8so2106013vbf.39
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:38:24 -0700 (PDT)
In-Reply-To: <20130324143525.GI6281@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 11:35 AM, Shawn Guo <shawn.guo@linaro.org> wrote:

> Are you sure?  After reverting the patch on next-20130322, I can get
> imx28 resume back to console as below.

Yes, please try 20130412, which has Frank's fix applied and try
suspend/resume sequence several times.

Does it work always for you?

On my mx28evk it usually fails.
