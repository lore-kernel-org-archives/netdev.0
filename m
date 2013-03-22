From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: put tx to napi poll function to
 fix dead lock
Date: Fri, 22 Mar 2013 16:00:26 -0300
Message-ID: <CAOMZO5B-ipzyb2uiLW12fFd3PD3JfLS8R0YLM5vtLgFNz8abUw@mail.gmail.com>
References: <1362368065-5809-1-git-send-email-Frank.Li@freescale.com>
	<20130320114824.GA6088@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>, B38611@freescale.com,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, lznuaa@gmail.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:60542 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab3CVTA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 15:00:27 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so3296915pbc.3
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 12:00:26 -0700 (PDT)
In-Reply-To: <20130320114824.GA6088@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 8:48 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> Frank,
>
> I'm running v3.9-rc3 image with NFS on imx6q, and seeing system fail
> to resume back.  The resume seems being stopped by fec driver.  If you
> wait long enough, you might see the repeated "eth0: tx queue full!."
> error message.

On mx28, only reverting this patch does not solve the suspend/resume issue.
