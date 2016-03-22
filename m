From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] macb: fix PHY reset
Date: Tue, 22 Mar 2016 16:07:38 -0400 (EDT)
Message-ID: <20160322.160738.145737905213296810.davem@redhat.com>
References: <3349780.3Prc3uV314@wasted.cogentembedded.com>
	<56F19E2D.8000700@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbcCVUHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 16:07:40 -0400
In-Reply-To: <56F19E2D.8000700@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 22 Mar 2016 22:34:05 +0300

> On 03/22/2016 10:27 PM, Sergei Shtylyov wrote:
> 
>> The driver calls gpiod_set_value() with GPIOD_OUT_* instead of 0 and
>> 1, as
>> a result the PHY isn't really put back into reset state in
>> macb_remove().
>> Moreover, the driver assumes that something else has set the GPIO
>> direction
>> to output, so if it has not, the PHY wouldn't be taken out of reset in
> 
>    s/wouldn't/may not/, sorry. Do I need to resend?

No need, I fixed it up by hand.

Applied, thanks.
