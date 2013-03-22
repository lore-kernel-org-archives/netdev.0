From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 3/3] net/macb: make clk_enable atomic
Date: Fri, 22 Mar 2013 14:38:39 -0300
Message-ID: <CAOMZO5BRDU_-fvv4PZQcLe-4OdZ4bDQ8m+nNHEFcC1Y2+zdh9g@mail.gmail.com>
References: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
	<1363973615-17863-3-git-send-email-s.trumtrar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:53199 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422661Ab3CVRik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 13:38:40 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so3251235pbc.3
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 10:38:40 -0700 (PDT)
In-Reply-To: <1363973615-17863-3-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 2:33 PM, Steffen Trumtrar
<s.trumtrar@pengutronix.de> wrote:
> Use clk_prepare_enable to be safe on SMP systems.

Wouldn't you have to use clk_disable_unprepare() now?
