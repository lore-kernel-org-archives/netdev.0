From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Sat, 13 Jun 2009 01:07:12 -0700 (PDT)
Message-ID: <20090613.010712.100174619.davem@davemloft.net>
References: <4A334E7A.5020805@gmail.com>
	<20090613.000729.118500646.davem@davemloft.net>
	<4A335A8A.5080907@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754108AbZFMIHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 04:07:09 -0400
In-Reply-To: <4A335A8A.5080907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Sat, 13 Jun 2009 09:51:38 +0200

> David Miller wrote:
>> But the situation is different, the physical hardware has a limitation
>> and know of this belongs, or should be described, in the driver
>> somehow.
>>   
> Theoretically I agree. However the only practical advantage I can see of
> doing it in the driver is that it is then impossible to later re-enable
> broken modes.

The bug is a hardware limitation.

The kernel programs and knows the hardware.

Therefore knowledge of the limitation belongs in the kernel.

In no other situation would we say "this aspect of this chip doesn't
work, so we'll block usage of that in some high level configuration
framework"

No, we'd always deal with HW problems in the driver itself.

You'd only re-enable the broken modes later when you know they
are working properly, in which case you can update the driver as
appropriate.  And this is what we'd do in other similar cases too.
