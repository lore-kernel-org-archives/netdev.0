From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND PATCH 1/3] e1000e: set CONFIG_E1000E=y in x86	defconfigs
Date: Mon, 23 Jun 2008 19:20:08 -0400
Message-ID: <48602FA8.7090508@garzik.org>
References: <20080622221916.5907.79563.stgit@localhost.localdomain> <20080623112618.GC7485@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39288 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997AbYFWXUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 19:20:14 -0400
In-Reply-To: <20080623112618.GC7485@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> From: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> This adds to the already default CONFIG_E1000=y in these files.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  arch/x86/configs/i386_defconfig   |    1 +
>>  arch/x86/configs/x86_64_defconfig |    1 +
> 
> that is not an e1000 patch but an arch/x86 defconfig patch. NAK on this 
> route of patch propagation.

But it's dependent on an e1000 patch.  Maybe we could follow the lead of 
ppc and other arch maintainers, and work together?

Typically if there are arch dependencies and little drivers/net changes, 
I'll ACK the drivers/net change and then let it go through the arch tree.

In this case, there is far more drivers/net code, so it would make the 
most sense to work with you to change the defconfigs to your liking, and 
then merge them via netdev when the other E1000 changes go in.

	Jeff




