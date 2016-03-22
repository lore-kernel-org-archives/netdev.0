From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] macb: fix PHY reset
Date: Wed, 23 Mar 2016 00:33:10 +0300
Message-ID: <56F1BA16.9070601@cogentembedded.com>
References: <3349780.3Prc3uV314@wasted.cogentembedded.com>
 <56F19E2D.8000700@cogentembedded.com>
 <20160322.160738.145737905213296810.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36411 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcCVVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 17:33:14 -0400
Received: by mail-lb0-f173.google.com with SMTP id qe11so119361111lbc.3
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 14:33:14 -0700 (PDT)
In-Reply-To: <20160322.160738.145737905213296810.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2016 11:07 PM, David Miller wrote:

>> On 03/22/2016 10:27 PM, Sergei Shtylyov wrote:
>>
>>> The driver calls gpiod_set_value() with GPIOD_OUT_* instead of 0 and
>>> 1, as
>>> a result the PHY isn't really put back into reset state in
>>> macb_remove().
>>> Moreover, the driver assumes that something else has set the GPIO
>>> direction
>>> to output, so if it has not, the PHY wouldn't be taken out of reset in
>>
>>     s/wouldn't/may not/, sorry. Do I need to resend?
>
> No need, I fixed it up by hand.
>
> Applied, thanks.

    Oops, forgot another tag:

Fixes: 270c499f0993 ("net/macb: Update device tree binding for resetting PHY 
using GPIO")

   Too late probably... :-(

MBR, Sergei
