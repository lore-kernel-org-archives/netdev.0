From: Ben Greear <greearb@candelatech.com>
Subject: Re: Bad tg3 performance on S10 netbook
Date: Wed, 14 Jan 2009 15:47:06 -0800
Message-ID: <496E797A.3070707@candelatech.com>
References: <496E64BB.7080709@candelatech.com> <1231975027.8964.136.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41448 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757092AbZANXrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 18:47:09 -0500
In-Reply-To: <1231975027.8964.136.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> On Wed, 2009-01-14 at 14:18 -0800, Ben Greear wrote:
>> We tried turning on adaptive-rx (it is off by default), and again,
>> no improvement.
> 
> tg3 does not support adaptive-rx.  It will be quietly ignored by the
> driver.  ethtool -c will show that it is always off after you try to
> turn it on.

Ok.  It seems that it was still something to do with the processor
idling or something like that.  We booted with acpi=off and now the
system runs better (no rx-miss).

We'll move to a newer kernel soon..maybe that will work better.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

