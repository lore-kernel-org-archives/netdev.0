From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] usbnet: Zero padding byte if there is tail room in skb
Date: Mon, 02 Jul 2007 08:25:24 -0400
Message-ID: <4688EEB4.1090506@garzik.org>
References: <87y7i5evv4.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david-b@pacbell.net
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50934 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757106AbXGBMZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:25:28 -0400
In-Reply-To: <87y7i5evv4.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> Usbnet adds a padding byte if a 0 byte USB packet would be sent. Zero
> padding byte if there is tail room in skb.
> 
> Signed-of-by: Peter Korsgaard <jacmet@sunsite.dk>
> Acked-by: David Brownell <dbrownell@users.sourceforge.net>
> 
> ---
>  drivers/net/usb/usbnet.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

applied


