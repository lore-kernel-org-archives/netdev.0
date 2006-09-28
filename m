From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 18:25:26 -0400
Message-ID: <451C4BD6.7050200@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>	<1159474625.3741.6.camel@rh4> <20060928.151358.01288837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22925 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161335AbWI1WZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 18:25:34 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060928.151358.01288837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 28 Sep 2006 13:17:04 -0700
> 
>> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
>> Dumping 64K worth of registers and blinking the LEDs should be
>> restricted.  But I have no problem doing these checks in the driver if
>> necessary.
> 
> Ok I removed PHYS_ID and GREGS from the allowed list.
> Any others?

GWOL now spits out a password for all users -> security risk.  Ditto 
GEEPROM.  GSET has been known to cause hangs if done in a tight loop, on 
some 10/100 cards, which is now permitted by any user.  At the very 
least, it should be rate-limited.

I wasn't just being obstinate, when requesting an audit.

	Jeff



