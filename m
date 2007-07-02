From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: Return 0 from bind() on success
Date: Mon, 02 Jul 2007 08:25:43 -0400
Message-ID: <4688EEC7.9090209@garzik.org>
References: <87y7i1p2w1.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50959 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015AbXGBMZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:25:45 -0400
In-Reply-To: <87y7i1p2w1.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> Fixup dm9601_bind() so it returns 0 on success rather than just a positive
> number, as otherwise usbnet doesn't init the status handler.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> 
> ---
>  drivers/net/usb/dm9601.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)

applied


