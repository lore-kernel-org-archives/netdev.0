From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1 v2 net-next] net: fec: fix the build as module
Date: Thu, 21 Mar 2013 23:36:20 -0300
Message-ID: <CAOMZO5D1p-QJ=7N-QrLbjcwK0b=280QEFuxNkbmYsmTeRitv+w@mail.gmail.com>
References: <1363915193-22179-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lznuaa@gmail.com, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:49895 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab3CVCgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 22:36:21 -0400
Received: by mail-vc0-f175.google.com with SMTP id hf12so2827231vcb.6
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 19:36:21 -0700 (PDT)
In-Reply-To: <1363915193-22179-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:19 PM, Frank Li <Frank.Li@freescale.com> wrote:
> Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff type) the
> following build error happens when CONFIG_FEC=m
>
> ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefined!
> ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefined!
> ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/fec.ko] undefined!

This error does not not happen in 'net-next' anymore.
