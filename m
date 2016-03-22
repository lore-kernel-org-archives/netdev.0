From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] macb: fix PHY reset
Date: Tue, 22 Mar 2016 22:34:05 +0300
Message-ID: <56F19E2D.8000700@cogentembedded.com>
References: <3349780.3Prc3uV314@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:32769 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcCVTeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:34:09 -0400
Received: by mail-lb0-f182.google.com with SMTP id oe12so172588969lbc.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 12:34:08 -0700 (PDT)
In-Reply-To: <3349780.3Prc3uV314@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2016 10:27 PM, Sergei Shtylyov wrote:

> The driver calls gpiod_set_value() with GPIOD_OUT_* instead of 0 and 1, as
> a result the PHY isn't really  put back into reset state in macb_remove().
> Moreover, the driver assumes that something else has set the GPIO direction
> to output, so if  it has not, the PHY wouldn't be taken out of reset in

    s/wouldn't/may not/, sorry. Do I need to resend?

> macb_probe() either...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
