From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH] e1000: remove unused Kconfig option for disabling
 packet split
Date: Wed, 24 Sep 2008 22:14:37 -0400
Message-ID: <48DAF40D.3040005@garzik.org>
References: <20080827081956.11114.152.stgit@jtkirshe-mobile.jf.intel.com> <48BE982C.20705@garzik.org> <Pine.WNT.4.63.0809161258170.3244@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56506 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbYIYCOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:14:45 -0400
In-Reply-To: <Pine.WNT.4.63.0809161258170.3244@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> On Wed, 3 Sep 2008, Jeff Garzik wrote:
>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>
>>> Since the e1000/e1000e split, no hardware supported by e1000
>>> supports packet split, just remove the Kconfig option and associated
>>> code from arch/* and the driver.
>>>
>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>
>>>  arch/arm/configs/iop13xx_defconfig              |    1
>>> arch/arm/configs/iop32x_defconfig               |    1
>> ACK, except for the defconfig changes.  arch maintainers usually prefer to do
>> that themselves.
>>
>> We'd be continually patch defconfig files, if we did so every time it was
>> likely one would be updated by a Kconfig patch.
> 
> Here is an updated patch without the defconfig changes
> 
> == cut here ==
> 
> e1000: remove Kconfig option for packet split and e1000 related code
> 
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Since the e1000/e1000e split, no hardware supported by e1000
> supports packet split, just remove the Kconfig option and associated
> code from the driver.
> 
> reposted without the defconfig changes, should apply to net-next
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>  drivers/net/Kconfig            |    9 -
>  drivers/net/e1000/e1000.h      |   17 --
>  drivers/net/e1000/e1000_main.c |  416 +---------------------------------------
>  3 files changed, 9 insertions(+), 433 deletions(-)

applied


