From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/1] lan78xx: Change default internal PHY ID to
 1
Date: Fri, 28 Aug 2015 01:25:52 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D54C7B2@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D54C326@CHN-SV-EXMX02.mchp-main.com>,<20150827.161719.2292798105218631656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:44704 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751449AbbH1BZy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 21:25:54 -0400
In-Reply-To: <20150827.161719.2292798105218631656.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for lack of details.

Default PHY ID is changed to 1 for final silicon.
This is an coding error to be included.

________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, August 27, 2015 7:17 PM
To: Woojung Huh - C21699
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net-next 1/1] lan78xx: Change default internal PHY ID to 1

From: <Woojung.Huh@microchip.com>
Date: Thu, 27 Aug 2015 18:01:17 +0000

> Change default internal PHY ID to 1.
>
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

This doesn't describe in enough details, this change.

Why is this being changed now?  How did the driver work properly with
the previous value?  If it worked previously, what negative things
could possibly happen using the new value?

You are providing zero context, and reasoning, for your change.  That
makes it impossible to review.
