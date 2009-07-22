From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Tue, 21 Jul 2009 20:56:45 -0700 (PDT)
Message-ID: <20090721.205645.234746177.davem@davemloft.net>
References: <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
	<20090722022745.GM8515@gospo.rdu.redhat.com>
	<5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, john.ronciak@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	stable@kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755566AbZGVD4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 23:56:39 -0400
In-Reply-To: <5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 21 Jul 2009 20:25:31 -0700

> My understanding was that the can_wakeup was supposed to be
> initialized by pci_pm_init or platform_pci_wakeup_init based on the
> pci-e capabilities.  Is this not the case?  It seems like this is
> where you should be looking to determine why the the can_wakeup isn't
> being initialized correctly.
> 
> The patch below won't solve the problem either.  The problem is that
> the can_wakeup value is being disabled when the EEPROM doesn't support
> WOL.
> 
> If you have to do this in the drivers, then my suggestion is to take a
> look at how ixgbe is doing it.  You essentially need to initialize
> can_wakeup to true, and then set the should_wakeup attribute based on
> the EEPROM setting or via ethtool.  This way you can still toggle the
> should_wakeup option without being blocked by the EEPROM disabling it.

It looks like the approach needs to be worked out still, so
I'm tossing these patches from patchwork.

Let me know when a more final fix is ready.

Thanks.
