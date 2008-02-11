From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] PS3: gelic: Fix the wrong dev_id passed
Date: Mon, 11 Feb 2008 10:31:49 -0500
Message-ID: <47B06A65.4030701@pobox.com>
References: <20080207195725.AD40.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52467 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbYBKPby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:31:54 -0500
In-Reply-To: <20080207195725.AD40.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Masakazu Mokuno wrote:
> PS3: gelic: Fix the wrong dev_id passed
> 
> The device id for lv1_net_set_interrupt_status_indicator() is wrong.
> This path would be invoked only in the case of an initialization failure.
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  drivers/net/ps3_gelic_net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied 1-7

Please do not duplicate the email subject -- the change's one-line 
summary -- as the first line of the email.  I had to hand-edit each of 
this duplicate information out, before applying the patches.


