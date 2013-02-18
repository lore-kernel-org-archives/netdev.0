From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v3] net: fec: Do a sanity check on the gpio number
Date: Mon, 18 Feb 2013 16:51:49 -0300
Message-ID: <CAOMZO5DyfksHf9CK9MUGmdwNPmwc2EXtY+3krNffYdivvPr=0Q@mail.gmail.com>
References: <1361114964-10517-1-git-send-email-festevam@gmail.com>
	<20130218.144754.591538350954943449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:34733 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757136Ab3BRTvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:51:50 -0500
Received: by mail-ve0-f177.google.com with SMTP id m1so5119094ves.8
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 11:51:49 -0800 (PST)
In-Reply-To: <20130218.144754.591538350954943449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 4:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Fabio Estevam <festevam@gmail.com>
> Date: Sun, 17 Feb 2013 12:29:24 -0300
>
>> Since commit 372e722ea4d (gpiolib: use descriptors internally) the following
>> warning is seen on a mx28evk board:
>
> [davem@drr linux]$ git describe 372e722ea4d
> fatal: Not a valid object name 372e722ea4d
> [davem@drr linux]$
>
> That commit ID doesn't exist in any tree I have access to.

It exists in linux-next.

Anyway, even without this commit the gpio validation should be done.

> I'm not applying this.

Ok, would you apply it if I remove the mention to 372e722ea4d from the
commit log?
