From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Wed, 07 Jan 2009 22:12:01 -0500
Message-ID: <49656F01.3090603@pobox.com>
References: <200901080203.SAA19103@tardy.cup.hp.com> <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40173 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbZAHDMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 22:12:09 -0500
In-Reply-To: <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Wed, 2009-01-07 at 18:03 -0800, Rick Jones wrote:
>> Certain Broadcom 10Gb Ethernet solutions (e.g. the 57711E) can have a
>> 10Gb port split into multiple virtual NICs each with an instance of
>> the bnx2x driver.  These virtual NICs can be configured for any speed
>> which is an integer multiple of 100 Mb/s from 100 to 10,000 Mbit/s
>> inclusive.  Since this is "normal" for such systems an "Unknown!" is
>> not indicated.
> [...]
> 
> The vetting of speeds is kind of silly.  Given that speed is established
> as being a number of Mbit/s (hence the need for speed_hi), why not
> remove the warning and the checks for known values and report it as
> such?

I'm ok with that route.  Historically it made sense, but AFAICS the 
driver _must_ verify the speed anyway, so removing the limitation in the 
userspace tool seems reasonable.

The next release of ethtool is coming in about 4 weeks, and we can 
definitely get something like this in there.

	Jeff



