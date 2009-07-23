From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Thu, 23 Jul 2009 11:06:47 -0700 (PDT)
Message-ID: <20090723.110647.228266156.davem@davemloft.net>
References: <5f2db9d90907212025k31c3a941v5fd1be9ed171e4c1@mail.gmail.com>
	<20090722193400.GN8515@gospo.rdu.redhat.com>
	<Pine.WNT.4.64.0907221642110.9900@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, alexander.duyck@gmail.com,
	john.ronciak@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, stable@kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868AbZGWSGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 14:06:41 -0400
In-Reply-To: <Pine.WNT.4.64.0907221642110.9900@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 22 Jul 2009 16:43:03 -0700 (Pacific Daylight Time)

> On Wed, 22 Jul 2009, Andy Gospodarek wrote:
> 
>> [PATCH] ixgbe: remove unnecessary call to device_init_wakeup
>> 
>> Calls to device_init_wakeup should not be necessary in drivers that use
>> device_set_wakeup_enable since pci_pm_init will set the can_wakeup flag
>> for the device when initialized.
>> 
>> I can't test this since I don't have any of the 82599 KX4 interfaces
>> (the only ones capable of WOL), but I did instrument ixgbe_probe and
>> know that can_wakeup=1 when device_init_wakeup is removed.
>> 
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
 ...
> Works just fine on two different 82599 mezz cards that support WoL.  
> Thanks Andy for finding and fixing.
> 
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied, thanks.
