From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline
 on newer core 2/Xeon Arch
Date: Wed, 30 Jun 2010 14:28:32 -0700 (PDT)
Message-ID: <20100630.142832.51275605.davem@davemloft.net>
References: <20100630043728.9224.64191.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757238Ab0F3V2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:28:18 -0400
In-Reply-To: <20100630043728.9224.64191.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:38:00 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> x86 architectures can handle unaligned accesses in hardware, and it has
> been shown that unaligned DMA accesses can be expensive on Nehalem
> architectures.  As such we should overwrite NET_IP_ALIGN to resolve
> this issue.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Can I get an x86'er ACK on this?  I can merge it in via net-next-2.6
which is probably most convenient for people who want to see the
networking performance effects of this change.
