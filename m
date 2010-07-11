From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH] bnx2x: add support for receive hashing
Date: Sun, 11 Jul 2010 03:02:17 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704DC@SJEXCHCCR02.corp.ad.broadcom.com>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FBFB@SJEXCHCCR02.corp.ad.broadcom.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
 <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
 <20100710.191242.70196353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3679 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617Ab0GKKC0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 06:02:26 -0400
In-Reply-To: <20100710.191242.70196353.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, July 11, 2010 5:13 AM
> To: therbert@google.com
> Cc: Vladislav Zolotarov; netdev@vger.kernel.org
> Subject: Re: [PATCH] bnx2x: add support for receive hashing
> 
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 7 Jul 2010 12:17:31 -0700
> 
> > It is to enable the device to provide the RSS hash in RX descriptor.
> > The hash severs two purposes now, it's used internally in the device
> > to perform RSS table lookup and also value in RX descriptor.  The
> > latter does not require multi-queue.  Strictly speaking, on a single
> > processor system without multqueue, it would be true that enabling the
> > RX hash on bnx2x is currently superfluous (notwithstanding some other
> > use of the hash might be implemented).
> 
> We intend to use the card provided RSS hash to optimize GSO
> flow comparisons at some point.

Could u explain what did u mean here, pls.? GSO is a Tx flow while RSS hash is generated for the ingress traffic.

> 
> There are other possible uses as well.

Could u elaborate, pls?

> 
> Therefore even in a single RX queue configuration, the driver
> should provide the hash if it can.

Providing an RSS hash adds an additional work to our FW and HW. We would like to understand why do we need to pay this penalty. And surely we don't want to pay it for a possible use. We'd prefer to pay it when it's really needed.

Thanks,
vlad


