From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RESEND PATCH 1/3] e1000e: set CONFIG_E1000E=y in x86 defconfigs
Date: Thu, 26 Jun 2008 14:39:50 +0200
Message-ID: <20080626123950.GR29619@elte.hu>
References: <20080622221916.5907.79563.stgit@localhost.localdomain> <20080623112618.GC7485@elte.hu> <48602FA8.7090508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:33975 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758297AbYFZMkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 08:40:13 -0400
Content-Disposition: inline
In-Reply-To: <48602FA8.7090508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jeff@garzik.org> wrote:

> Ingo Molnar wrote:
>> * Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>>
>>> From: Auke Kok <auke-jan.h.kok@intel.com>
>>>
>>> This adds to the already default CONFIG_E1000=y in these files.
>>>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>
>>>  arch/x86/configs/i386_defconfig   |    1 +
>>>  arch/x86/configs/x86_64_defconfig |    1 +
>>
>> that is not an e1000 patch but an arch/x86 defconfig patch. NAK on this 
>> route of patch propagation.
>
> But it's dependent on an e1000 patch.  Maybe we could follow the lead 
> of ppc and other arch maintainers, and work together?
>
> Typically if there are arch dependencies and little drivers/net 
> changes, I'll ACK the drivers/net change and then let it go through 
> the arch tree.
>
> In this case, there is far more drivers/net code, so it would make the 
> most sense to work with you to change the defconfigs to your liking, 
> and then merge them via netdev when the other E1000 changes go in.

the normal flow for defconfig changes is to first do the driver changes, 
then later on propagate anything that is needed into the defconfig, once 
the driver change is upstream.

for example we've already got this queued up in tip/x86:

| commit b5d958ea66ac11b1190c24f042f517adf9229a98
| Author: Auke Kok <auke-jan.h.kok@intel.com>
| Date:   Wed Apr 9 13:17:39 2008 -0700
|
|    e1000e: set CONFIG_E1000E=y in x86 defconfigs
|
|    This adds to the already default CONFIG_E1000=y in these files.

and there's a fair number of other changes as well to the defconfigs for 
v2.6.27 which might collide. So it would be nice to keep it separate 
please.

	Ingo
