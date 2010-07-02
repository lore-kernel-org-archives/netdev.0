From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] x86: Drop CONFIG_MCORE2 check around
 setting of NET_IP_ALIGN
Date: Thu, 01 Jul 2010 22:49:47 -0700 (PDT)
Message-ID: <20100701.224947.22524376.davem@davemloft.net>
References: <20100701232742.15934.49030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	ak@linux.intel.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325Ab0GBFte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:49:34 -0400
In-Reply-To: <20100701232742.15934.49030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:28:27 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch removes the CONFIG_MCORE2 check from around NET_IP_ALIGN.  It is
> based on a suggestion from Andi Kleen.  The assumption is that there are
> not any x86 cores where unaligned access is really slow, and this change
> would allow for a performance improvement to still exist on configurations
> that are not necessarily optimized for Core 2.
> 
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, with HPA's ack.
