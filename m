From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Fri, 12 Jun 2009 04:33:50 -0700 (PDT)
Message-ID: <20090612.043350.38954875.davem@davemloft.net>
References: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
	<20090611.170948.66762524.davem@davemloft.net>
	<20090612105019.GA21599@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mfuzzey@gmail.com, bhutchings@solarflare.com, nico@cam.org,
	netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754547AbZFLLds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 07:33:48 -0400
In-Reply-To: <20090612105019.GA21599@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Fri, 12 Jun 2009 11:50:20 +0100

> On Thu, Jun 11, 2009 at 05:09:48PM -0700, David Miller wrote:
> 
>> You can instantiate a platform_device that the driver matches
>> and uses to acquire board-specific-juju such as link modes
>> which are non-functional.
> 
> How would you handle PCI devices in that scheme?  Last time I looked at
> this (a while ago, so I may be out of date) there didn't appear to be a
> sensible generic way of getting platform data to PCI devices.

It's irrelevant in this discussion because in the contexts where
this is wanted, people are adding driver-wide hacks to make
these settings.

So a dummy platform_device would serve handily.

For PCI, in general, the VPD or openfirmware descriptions could
be used to describe such issues.
