From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Mon, 27 Jul 2015 14:29:37 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D53333C@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D530DCF@CHN-SV-EXMX02.mchp-main.com>
 <20150726.164217.2175444603653367329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:53735 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751308AbbG0O3i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 10:29:38 -0400
In-Reply-To: <20150726.164217.2175444603653367329.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your review.
I'll repost updated patch again.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, July 26, 2015 7:42 PM
> To: Woojung Huh - C21699
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
> 10/100/1000 Ethernet device driver
> 
> From: <Woojung.Huh@microchip.com>
> Date: Wed, 22 Jul 2015 19:01:44 +0000
> 
> > - remove module param which can be configurable by standard mechanism.
> 
> You still left some unacceptable module parameters in here.
> 
> The only one which is fine is the debug level setting, that's
> it.
> 
> There is no way in I'm applying a patch that allows programming
> registers of the chip directly via module parameters, no way.
