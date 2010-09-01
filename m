From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] bnx2x: Minor link related fixes
Date: Wed, 01 Sep 2010 12:01:37 -0700 (PDT)
Message-ID: <20100901.120137.84370412.davem@davemloft.net>
References: <1283370674.4403.131.camel@lb-tlvb-yanivr.il.broadcom.com>
	<20100901.104524.216750458.davem@davemloft.net>
	<1283366622.5874.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yaniv.rosner@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755212Ab0IATBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 15:01:21 -0400
In-Reply-To: <1283366622.5874.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 1 Sep 2010 21:43:42 +0300

> On Wed, 2010-09-01 at 10:45 -0700, David Miller wrote:
>> Can you explain why 10mbit/100mbit links have to use forced link mode
>> and do not use autonegotiation by default?  I could understand for
>> 10mbit but 100mbit too?
>> 
> Our understanding of the requirements is that if the user selects force
> speed of 1G or higher, it is recommended to use autonegotiation with
> only that speed advertized. However, when the user selects force speed
> of 10M or 100M, assuming the other side is actually forcing the speed,
> using autonegotiation will fail and fall back to parallel detect and
> that will establish link in HD mode (as required) while the other side
> is likely to be using FD this will cause duplex mismatch and many
> errors, so it is best to keep 10M/100M truly forced to support older
> link partners.

I see, thanks for the explanation.
