From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]  hso.c against 2.6.27-rc5 throttle/unthrottle to prevent
 loss of serial data, second attempt
Date: Sat, 13 Sep 2008 19:07:18 -0400
Message-ID: <48CC47A6.9050205@garzik.org>
References: <48C14C47.1050705@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57878 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbYIMXHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 19:07:22 -0400
In-Reply-To: <48C14C47.1050705@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Joseph Barrow wrote:
> Hi Guys,
> This is a slightly smaller patch without
> the unneccessary code that Alan Cox pointed out was superflous.
> 
> The firmware engineers have been patting me on the back
> for the previous version of this patch as the serial ports
> no longer drop characters.
> 
> Patch to stop loss of characters on the hso modems,
> this patch throttles & unthrottles the modem by
> not putting out urbs until the tty/line discipline layer
> has enough space for newly received packets.
> serial ports. This is required for firmware diagnostics
> being done at Option.
> Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>

applied


