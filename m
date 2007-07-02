From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: HW header size shouldn't be included in packet
 length
Date: Mon, 02 Jul 2007 08:25:16 -0400
Message-ID: <4688EEAC.8040801@garzik.org>
References: <873b0dgbz9.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50922 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbXGBMZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:25:19 -0400
In-Reply-To: <873b0dgbz9.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> The dm9601 driver was including the 2 byte hardware header in the
> packet length, causing the HW to send 2 extra bytes of garbage on tx.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> 
> ---
>  drivers/net/usb/dm9601.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

applied


