From: David Miller <davem@davemloft.net>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 05 Jul 2006 11:21:09 -0700 (PDT)
Message-ID: <20060705.112109.74731123.davem@davemloft.net>
References: <1152033116.5276.22.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, auke-jan.h.kok@intel.com,
	greearb@candelatech.com, john.ronciak@intel.com,
	Robert.Olsson@data.slu.se, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12494
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964957AbWGESUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:20:46 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152033116.5276.22.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 04 Jul 2006 13:11:56 -0400

> Clearly, this is a bad thing. Yes, the device in the first instance was
> at fault. But i have argued in the past that NAPI does just fine without
> flow control being turned on, so even chewing 5% of bandwidth on flow
> control is a bad thing..

I think it should be on by default.

If the machine is really busy, proper flow control keeps the
sender from overflowing the RX ring of the receiver.

Yes, with NAPI this happens less, but it does still happen.  And
I know that this is probably one of the least tested code paths
in every single driver, RX ring emptying out, and in fact the Tigon2
and the earliest Tigon3 chips would lock up on you if the RX ring
was emptied completely requiring a full chip reset when the watchdog
timer fired.
