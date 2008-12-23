From: Santwona.Behera@Sun.COM
Subject: Re: [PATCH 2/3] Add support for RX packet classification in a network
 device
Date: Mon, 22 Dec 2008 16:36:31 -0800
Message-ID: <4950328F.9020409@Sun.COM>
References: <494FE060.8020600@Sun.COM> <1229974033.3077.14.camel@achroite>
 <49501CEF.8010101@Sun.COM> <1229991408.3077.19.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:32908 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbYLWAge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 19:36:34 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id mBN0aXDL008804
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2008 16:36:33 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0KCB00C0108O4Y00@fe-sfbay-09.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Mon,
 22 Dec 2008 16:36:33 -0800 (PST)
In-reply-to: <1229991408.3077.19.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>> 1. I change AH_ESP_Vx_FLOW defines to AH_Vx_FLOW defines and add 2 new 
>> defines for ESP_Vx_FLOW at the end, with values 0x9 and 0xa.
> 
> If AH_ESP_Vx_FLOW has only ever been implemented as AH-only then perhaps
> this is reasonable.
> 
>> 2. I keep the AH_ESP_Vx_FLOW defines as is (but this will be dead code 
>> as it will not be used) and add 2 new AH_Vx_FLOW defines and 2 new 
>> ESP_Vx_FLOW defines at the end with values 0x9, 0xa, 0xb, 0xc.
> 
> This is safest.

OK, I will re-implement it this way then.

> 
> Also you are probably right to remove RXH_DEV_PORT as that appears to be
> an niu quirk that shouldn't be exposed.

That was the reasoning behind removing RXH_DEV_PORT.

rgds,
--santwona
