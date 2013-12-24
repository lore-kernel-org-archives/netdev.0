From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] fec: Do not assume that PHY reset is active low
Date: Tue, 24 Dec 2013 12:38:14 -0200
Message-ID: <CAOMZO5BaKdhx=K19scS2HPz1KNt1sZApt651_Tvqg5q0N5xnEA@mail.gmail.com>
References: <1387895590-32333-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Philipp Zabel <p.zabel@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:38779 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab3LXOiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 09:38:15 -0500
Received: by mail-vc0-f174.google.com with SMTP id if17so2882033vcb.5
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 06:38:14 -0800 (PST)
In-Reply-To: <1387895590-32333-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 12:33 PM, Fabio Estevam <festevam@gmail.com> wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>
> We should not assume that the PHY reset is always active low.
>
> Retrieve this information from the device tree instead, so that the PHY reset
> can work on both cases.
>
> Reported-by: Philipp Zabel <p.zabel@pengutronix.de>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Changes since v1:
> - Fix the initial state of the GPIOs

Sorry, v1 was the correct one. Please discard v2.
