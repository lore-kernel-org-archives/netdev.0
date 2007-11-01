From: Ben Greear <greearb@candelatech.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 08:04:31 -0700
Message-ID: <4729EAFF.9050606@candelatech.com>
References: <20071031123359.3954befc@freepuppy.rosehill>	<4729269A.6090606@candelatech.com>	<47292A99.5070805@linux-foundation.org> <20071031.215025.195350296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:43999 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbXKAPEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 11:04:45 -0400
In-Reply-To: <20071031.215025.195350296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 31 Oct 2007 18:23:37 -0700
>
>   
>> The code in AF_PACKET should fix the skb before passing to user
>> space so that there is no difference between accel and non-accel
>> hardware.  Internal choices shouldn't leak to user space.  Ditto,
>> the receive checksum offload should be fixed up as well.
>>     
>
> The hardware has stripped the VLAN header completely and has not
> provided it to us at all.
>   
Do the NICs not save the QoS bits in the VLAN header anywhere that we could
use to reconstitute the header?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


