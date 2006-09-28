From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 16:23:46 -0400
Message-ID: <451C2F52.6040003@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22151 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751509AbWI1UXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 16:23:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> There is no reason to not allow non-admin users to query network
> statistics and settings.

NAK.

Some functions in the past didn't like getting hit rapidly in succession.

I would agree to this, but only after an exhaustive audit of each driver 
and each sub-ioctl.  Right now, I only have confidence in GDRVINFO 
probably being safe -- but still that requires an audit, since in rare 
cases the driver may be poking firmware and eeprom areas.

Finally, I fixed a buffer overflow in ethtool version 5, so an audit to 
make sure overflows cannot affect the kernel is basically _required_.

	Jeff




