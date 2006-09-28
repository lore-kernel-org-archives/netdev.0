From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 16:35:48 -0400
Message-ID: <451C3224.8030903@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net> <1159474625.3741.6.camel@rh4> <Pine.LNX.4.64.0609281632200.28620@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51847 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750717AbWI1Ufv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 16:35:51 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609281632200.28620@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Thu, 28 Sep 2006, Michael Chan wrote:
> 
>> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
>> Dumping 64K worth of registers and blinking the LEDs should be
>> restricted.
> 
> Out of curiosity -- why?

In the past, dumping certain tg3 registers has led to lock-ups, for one.

Also, blindly dumping registers can negatively affect driver operation, 
for the case where reading registers has side effects, such as PHY 
register bit shifting, or read-and-clear registers.

	Jeff



