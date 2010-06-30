From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline
 on newer core 2/Xeon Arch
Date: Wed, 30 Jun 2010 14:32:33 -0700
Message-ID: <4C2BB7F1.6050009@zytor.com>
References: <20100630043728.9224.64191.stgit@localhost.localdomain> <20100630.142832.51275605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, tglx@linutronix.de,
	mingo@redhat.com, x86@kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:46047 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab0F3Vcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 17:32:54 -0400
In-Reply-To: <20100630.142832.51275605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2010 02:28 PM, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 29 Jun 2010 21:38:00 -0700
> 
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> x86 architectures can handle unaligned accesses in hardware, and it has
>> been shown that unaligned DMA accesses can be expensive on Nehalem
>> architectures.  As such we should overwrite NET_IP_ALIGN to resolve
>> this issue.
>>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Cc: x86@kernel.org
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Can I get an x86'er ACK on this?  I can merge it in via net-next-2.6
> which is probably most convenient for people who want to see the
> networking performance effects of this change.

Acked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa
